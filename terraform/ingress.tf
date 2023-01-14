resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.24.3"

  namespace        = "traefik-system"
  create_namespace = true

  # Não pode esperar porque as configurações do load-balance acontecem
  # em outro passo, então, vai ficar como pending até lá.
  wait = false

  values = [
    <<-EOT
    additionalArguments:
      - --entryPoints.web.http.redirections.entryPoint.to=websecure
      - --entryPoints.web.http.redirections.entryPoint.scheme=https

    service:
      annotations:
        metallb.universe.tf/address-pool: cloud-provider

    ingressClass:
      enabled: true
      isDefaultClass: true

    ingressRoute:
      dashboard:
        enabled: false

    ports:
      web:
        port: 80
      websecure:
        asDefault: true
        port: 443
    EOT
  ]
}

resource "kubernetes_manifest" "traefik_dashboard_certificate" {
  provider = kubernetes.step_2

  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: Certificate

    metadata:
      name: traefik-dashboard
      namespace: ${helm_release.traefik.namespace}

    spec:
      dnsNames:
        - traefik.network.k8s.homecluster.local
      secretName: traefik-dashboard-tls
      issuerRef:
        name: ${kubernetes_manifest.cert_manager_cluster_issuer.manifest.metadata.name}
        kind: ClusterIssuer
    EOT
  )
}

resource "kubernetes_manifest" "traefik_dashboard" {
  provider = kubernetes.step_2

  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute

    metadata:
      name: dashboard
      namespace: ${helm_release.traefik.namespace}

    spec:
      entryPoints:
        - websecure

      routes:
        - match: Host(`${kubernetes_manifest.traefik_dashboard_certificate.manifest.spec.dnsNames[0]}`)
          kind: Rule
          services:
            - name: api@internal
              kind: TraefikService

      tls:
        secretName: ${kubernetes_manifest.traefik_dashboard_certificate.manifest.spec.secretName}
    EOT
  )
}
