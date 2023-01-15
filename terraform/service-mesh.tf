# Depois de instalar o cluster todo é preciso executar o
# seguinte comando para que o linkerd injete o proxy:
# for ns in $(kubectl get namespaces -o 'name' | cut -d '/' -f2); do kubectl rollout restart deployment -n $ns; done

resource "kubernetes_namespace" "linkerd" {
  provider = kubernetes.step_2

  metadata {
    name = "linkerd"
    labels = {
      "config.linkerd.io/admission-webhooks" = "disabled",
    }
  }
}

resource "kubernetes_manifest" "linkerd_ca_certificate" {
  provider = kubernetes.step_2

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
  provider = kubernetes.step_2

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
  provider = kubernetes.step_2

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

data "kubernetes_secret" "linkerd_certificate" {
  provider = kubernetes.step_2

  metadata {
    name      = kubernetes_manifest.linkerd_certificate.manifest.spec.secretName
    namespace = kubernetes_namespace.linkerd.metadata[0].name
  }
}

resource "helm_release" "linkerd_crds" {
  provider = helm.step_2

  name       = "linkerd-crds"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-crds"
  version    = "1.4.0"

  namespace        = kubernetes_namespace.linkerd.metadata[0].name
  create_namespace = false
  wait_for_jobs    = true
}

resource "helm_release" "linkerd_control_plane" {
  provider = helm.step_2

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
    <<-EOT
    identity:
      issuer:
        scheme: kubernetes.io/tls
    podMonitor:
      enabled: true
    EOT
  ]

  depends_on = [
    helm_release.kube_prometheus,
  ]
}

resource "helm_release" "linkerd_viz" {
  provider = helm.step_2

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
    prometheusUrl: http://prometheus-operated.${helm_release.kube_prometheus.namespace}.svc.cluster.local:9090
    prometheus:
      enabled: false
    EOT
  ]
}
