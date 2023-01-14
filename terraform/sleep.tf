resource "time_sleep" "wait_k3s_agents" {
  create_duration = "30s"

  depends_on = [
    module.k3s_agents,
  ]
}

resource "time_sleep" "wait_kubeapi_ip" {
  create_duration = "60s"

  triggers = {
    kubeapi_ip    = module.k3s_servers.kubeapi_ip
    kubeconf_host = module.k3s_servers.kubeconf.cluster.host
  }

  depends_on = [
    module.kubeovn,
    module.kube_vip,
  ]
}

resource "time_sleep" "wait_helm" {
  create_duration = "60s"

  triggers = {
    kubeapi_ip    = module.k3s_servers.kubeapi_ip
    kubeconf_host = module.k3s_servers.kubeconf.cluster.host
  }

  depends_on = [
    helm_release.metallb,
    helm_release.cert_manager,
  ]
}
