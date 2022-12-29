resource "kubernetes_service_account" "kube_vip" {
  metadata {
    name      = "kube-vip"
    namespace = local.envs.cp_namespace
  }
}
