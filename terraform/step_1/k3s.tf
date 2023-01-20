module "k3s_servers" {
  source = "./modules/k3s/server"

  versioning = {
    version = "v1.25"
  }

  kubeapi_ip = local.kubeapi_ip

  nodes = local.server_nodes
  extra_commands = [
    "--etcd-expose-metrics",

    # configuração usada em produção
    "--disable=coredns,servicelb,traefik,local-storage,metrics-server",

    # configuração usada nos testes locais
    # "--disable=coredns,servicelb,traefik,metrics-server",
    # "--default-local-storage-path=/mnt",

    "--flannel-backend=none",
    "--disable-helm-controller",
    "--cluster-cidr=${local.pods_cidr}",
    "--service-cidr=${local.svcs_cidr}",
    "--cluster-dns=${local.coredns_ip}",
  ]
}

module "k3s_agents" {
  source = "./modules/k3s/agent"

  versioning = module.k3s_servers.versioning
  token      = module.k3s_servers.agent_token
  kubeapi_ip = module.k3s_servers.kubeapi_ip
  nodes      = local.agent_nodes

  depends_on = [
    module.kube_vip,
    module.kubeovn,
  ]
}

resource "time_sleep" "wait_k3s_agents" {
  create_duration = "30s"

  depends_on = [
    module.k3s_agents,
  ]
}
