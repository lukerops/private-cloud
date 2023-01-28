resource "kubernetes_manifest" "metallb_l2advertisement" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: production
      namespace: ${data.terraform_remote_state.step_2.outputs.tools.metallb.namespace}
    EOT
  )
}

resource "kubernetes_manifest" "metallb_ipaddresspool" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: cloud-provider
      namespace: ${data.terraform_remote_state.step_2.outputs.tools.metallb.namespace}
    spec:
      addresses:
        - 10.8.0.208/28
    EOT
  )
}
