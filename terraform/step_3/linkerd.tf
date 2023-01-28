# Depois de instalar o cluster todo é preciso executar o
# seguinte comando para que o linkerd injete o proxy:
# for ns in $(kubectl get namespaces -o 'name' | cut -d '/' -f2); do kubectl rollout restart deployment -n $ns; done

resource "kubernetes_namespace" "linkerd" {
  metadata {
    name = "linkerd"
    labels = {
      "config.linkerd.io/admission-webhooks" = "disabled",
    }
  }
}

resource "kubernetes_manifest" "linkerd_ca_certificate" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: linkerd-trust-anchor
      namespace: ${kubernetes_namespace.linkerd.metadata[0].name}
    spec:
      isCA: true
      commonName: root.linkerd.cluster.local
      secretName: linkerd-trust-anchor
      dnsNames:
        - root.linkerd.cluster.local
      subject:
        organizations:
          - kubernetes
        organizationalUnits:
          - linkerd
      duration: ${24 * 30 * 12}h0m0s # valido por 1 ano
      renewBefore: ${24 * 30 * 11}h0m0s # renova a cada 11 meses
      privateKey:
        algorithm: ECDSA
        size: 256
      issuerRef:
        name: ${kubernetes_manifest.cert_manager_cluster_issuer.manifest.metadata.name}
        kind: ClusterIssuer
        group: cert-manager.io
      usages:
      - cert sign
      - crl sign
    EOT
  )
}

resource "kubernetes_manifest" "linkerd_issuer" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: linkerd-trust-anchor
      namespace: ${kubernetes_namespace.linkerd.metadata[0].name}
    spec:
      ca:
        secretName: ${kubernetes_manifest.linkerd_ca_certificate.manifest.spec.secretName}
    EOT
  )
}

resource "kubernetes_manifest" "linkerd_certificate" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: linkerd-identity-issuer
      namespace: ${kubernetes_namespace.linkerd.metadata[0].name}
    spec:
      secretName: linkerd-identity-issuer
      duration: 48h0m0s
      renewBefore: 25h0m0s
      issuerRef:
        name: ${kubernetes_manifest.linkerd_issuer.manifest.metadata.name}
        kind: Issuer
      commonName: identity.linkerd.cluster.local
      dnsNames:
      - identity.linkerd.cluster.local
      isCA: true
      privateKey:
        algorithm: ECDSA
      usages:
      - cert sign
      - crl sign
      - server auth
      - client auth
    EOT
  )
}

resource "time_sleep" "wait_linkerd_certificate_secret" {
  create_duration = "60s"

  triggers = {
    secretName = kubernetes_manifest.linkerd_certificate.manifest.spec.secretName
  }

  lifecycle {
    replace_triggered_by = [
      kubernetes_manifest.linkerd_certificate.manifest,
    ]
  }
}

data "kubernetes_secret" "linkerd_certificate" {
  metadata {
    name      = time_sleep.wait_linkerd_certificate_secret.triggers.secretName
    namespace = kubernetes_namespace.linkerd.metadata[0].name
  }
}

resource "helm_release" "linkerd_crds" {
  name       = "linkerd-crds"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-crds"
  version    = "1.4.0"

  namespace        = kubernetes_namespace.linkerd.metadata[0].name
  create_namespace = false
  wait_for_jobs    = true
}

data "http" "linkerd_control_plane_ha" {
  url = "https://raw.githubusercontent.com/linkerd/linkerd2/stable-2.12.3/charts/linkerd-control-plane/values-ha.yaml"
}

resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = helm_release.linkerd_crds.repository
  chart      = "linkerd-control-plane"
  version    = "1.9.5"

  namespace        = helm_release.linkerd_crds.namespace
  create_namespace = false
  wait_for_jobs    = true

  set_sensitive {
    name  = "identityTrustAnchorsPEM"
    value = data.kubernetes_secret.linkerd_certificate.data["ca.crt"]
  }

  values = [
    data.http.linkerd_control_plane_ha.response_body,
    <<-EOT
    identity:
      issuer:
        scheme: kubernetes.io/tls
    podMonitor:
      enabled: true

    # TODO: remover quando tiver 3+ agent nodes
    enablePodAntiAffinity: false
    EOT
  ]
}

resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = helm_release.linkerd_control_plane.repository
  chart      = "linkerd-viz"
  version    = "30.3.5"

  namespace        = "linkerd-viz"
  create_namespace = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    linkerdNamespace: ${helm_release.linkerd_crds.namespace}
    linkerdVersion: ${helm_release.linkerd_control_plane.metadata[0].app_version}
    prometheusUrl: http://prometheus-operated.${data.terraform_remote_state.step_2.outputs.tools.kube_prometheus_stack.namespace}.svc.cluster.local:9090
    prometheus:
      enabled: false
    EOT
  ]
}

# Precisamos remover o Header Origin para que o tap funcione
# https://github.com/linkerd/linkerd2/issues/5897
resource "kubernetes_manifest" "linkerd_traefik_middleware" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
      name: linkerd-viz-dashboard-header
      namespace: ${helm_release.linkerd_viz.namespace}
    spec:
      headers:
        customRequestHeaders:
          Host: "web.linkerd-viz.svc.cluster.local"
          Origin: ""
          l5d-dst-override: "web.linkerd-viz.svc.cluster.local:8084"
    EOT
  )
}

resource "kubernetes_manifest" "ingress_linkerd_viz" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: linkerd-viz-dashboard
      namespace: ${helm_release.linkerd_viz.namespace}
      annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
        traefik.ingress.kubernetes.io/router.tls: "true"
        traefik.ingress.kubernetes.io/router.middlewares: ${helm_release.linkerd_viz.namespace}-${kubernetes_manifest.linkerd_traefik_middleware.manifest.metadata.name}@kubernetescrd
        cert-manager.io/cluster-issuer: selfsigned
    spec:
      ingressClassName: traefik
      rules:
        - host: linkerd.network.k8s.homecluster.local
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: web
                    port:
                      number: 8084
      tls:
        - secretName: linkerd-viz-dashboard-tls
          hosts:
            - linkerd.network.k8s.homecluster.local
    EOT
  )
}

# resource "kubernetes_ingress_v1" "linkerd_viz" {
#   metadata {
#     name      = "linkerd-viz-dashboard"
#     namespace = helm_release.linkerd_viz.namespace
#     annotations = {
#       "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
#       "traefik.ingress.kubernetes.io/router.tls"         = "true"
#       "traefik.ingress.kubernetes.io/router.middlewares" = "${helm_release.linkerd_viz.namespace}-${kubernetes_manifest.linkerd_traefik_middleware.manifest.metadata.name}@kubernetescrd"
#       "cert-manager.io/cluster-issuer"                   = "selfsigned"
#     }
#   }
#   spec {
#     ingress_class_name = "traefik"
#     rule {
#       host = "linkerd.network.k8s.homecluster.local"
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = "web"
#               port {
#                 number = 8084
#               }
#             }
#           }
#         }
#       }
#     }
#     tls {
#       hosts       = ["linkerd.network.k8s.homecluster.local"]
#       secret_name = "linkerd-viz-dashboard-tls"
#     }
#   }
# }
