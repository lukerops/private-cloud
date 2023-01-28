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
      clusterIP: ${data.terraform_remote_state.step_1.outputs.coredns_ip}
    resources:
      requests:
        memory: 70Mi
    podAnnotations:
      linkerd.io/inject: enabled
    EOT
  ]
}
