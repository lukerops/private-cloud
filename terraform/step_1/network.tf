module "kube_vip" {
  source = "./modules/kubevip"

  versioning = {
    version = "v0.5.7"
  }

  address   = module.k3s_servers.kubeapi_ip
  interface = "eth0"
}

module "kubeovn" {
  source = "./modules/kubeovn"

  versioning = {
    version = "v1.11.0"
  }

  node     = local.server_nodes[0]
  pod_cidr = local.pods_cidr
  svc_cidr = local.svcs_cidr

  depends_on = [
    module.k3s_servers,
  ]
}
