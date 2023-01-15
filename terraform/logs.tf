resource "helm_release" "loki_stack" {
  provider = helm.step_1

  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.8.9"

  namespace        = "loki"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  depends_on = [
    helm_release.kube_prometheus,
  ]
}
