resource "kubernetes_cluster_role" "kube_vip_role" {
  metadata {
    name = "system:kube-vip-role"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services", "services/status", "nodes", "endpoints"]
    verbs      = ["list", "get", "watch", "update"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["list", "get", "watch", "update", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "kube_vip_binding" {
  metadata {
    name = "system:kube-vip-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kube_vip_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_vip.metadata[0].name
    namespace = kubernetes_service_account.kube_vip.metadata[0].namespace
  }
}
