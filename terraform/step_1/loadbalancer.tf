resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.7"

  namespace        = "metallb-system"
  create_namespace = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    controller:
      podAnnotations:
        linkerd.io/inject: enabled
    EOT
  ]
}
