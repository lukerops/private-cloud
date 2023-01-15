resource "helm_release" "metallb" {
  provider = helm.step_1

  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.7"

  namespace        = "metallb-system"
  create_namespace = true
  wait_for_jobs    = true
}

resource "kubernetes_manifest" "metallb_l2advertisement" {
  provider = kubernetes.step_2

  manifest = yamldecode(
    <<-EOT
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: production
      namespace: ${helm_release.metallb.namespace}
    EOT
  )
}

resource "kubernetes_manifest" "metallb_ipaddresspool" {
  provider = kubernetes.step_2

  manifest = yamldecode(
    <<-EOT
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: cloud-provider
      namespace: ${helm_release.metallb.namespace}
    spec:
      addresses:
        - 10.254.0.208/28
    EOT
  )
}
