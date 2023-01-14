resource "helm_release" "coredns" {
  provider = helm.step_1

  name       = "coredns"
  repository = "https://coredns.github.io/helm"
  chart      = "coredns"
  version    = "1.19.7"

  namespace     = "kube-system"
  wait_for_jobs = true

  values = [
    <<-EOT
    service:
      clusterIP: ${local.coredns_ip}

    resources:
      requests:
        memory: 70Mi
    EOT
  ]
}
