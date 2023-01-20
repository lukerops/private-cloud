resource "kubernetes_manifest" "traefik_dashboard_certificate" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: traefik-dashboard
      namespace: ${data.terraform_remote_state.step_1.outputs.tools.traefik.namespace}
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
  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: IngressRoute
    metadata:
      name: dashboard
      namespace: ${data.terraform_remote_state.step_1.outputs.tools.traefik.namespace}
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
