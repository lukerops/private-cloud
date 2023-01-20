resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: selfsigned
    spec:
      selfSigned: {}
    EOT
  )
}
