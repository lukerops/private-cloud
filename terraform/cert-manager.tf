resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.11.0"

  namespace        = "cert-manager"
  create_namespace = true
  wait             = true

  values = [
    <<-EOT
    installCRDs: true

    prometheus:
      servicemonitor:
        enabled: true

    webhook:
      networkPolicy:
        enabled: false
    EOT
  ]
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  provider = kubernetes.step_2

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
