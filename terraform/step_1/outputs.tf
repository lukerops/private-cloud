output "nodes" {
  value = {
    server = local.server_nodes
    agent  = local.agent_nodes
  }
}

output "kubeconf" {
  value     = module.k3s_servers.kubeconf
  sensitive = true
}

output "kubeapi_ip" {
  value = module.k3s_servers.kubeapi_ip
}

output "coredns_ip" {
  value = local.coredns_ip
}

output "tools" {
  value = {
    kube_vip = {
      namespace = "kube-system"
      versions = {
        app = module.kube_vip.version
      }
    }
    kube_ovn = {
      namespace = "kube-system"
      versions = {
        app = module.kubeovn.version
      }
    }
  }
}
