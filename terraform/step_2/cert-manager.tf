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
    podAnnotations:
      linkerd.io/inject: enabled
    EOT
  ]

  depends_on = [
    helm_release.kube_prometheus_stack,
  ]
}
