resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.8.9"

  namespace        = "loki-stack"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    loki:
      podAnnotations:
        linkerd.io/inject: enabled
    promtail:
      podAnnotations:
        linkerd.io/inject: enabled
    EOT
  ]

  depends_on = [
    helm_release.kube_prometheus_stack,
  ]
}
