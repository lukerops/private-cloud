resource "helm_release" "coredns" {
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

  depends_on = [
    module.k3s_agents,
  ]
}
