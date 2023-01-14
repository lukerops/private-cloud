resource "helm_release" "metrics_server" {
  provider = helm.step_1

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.8.2"

  namespace     = "kube-system"
  wait          = true
  wait_for_jobs = true

  values = [
    <<-EOT
    metrics:
      enabled: true
    EOT
  ]

  depends_on = [
    helm_release.kube_prometheus,
  ]
}
