resource "time_sleep" "wait_kubernetes_step_1" {
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

resource "time_sleep" "wait_helm_step_1" {
  create_duration = "60s"

  triggers = {
    kubeapi_ip    = module.k3s_servers.kubeapi_ip
    kubeconf_host = module.k3s_servers.kubeconf.cluster.host
  }

  depends_on = [
    helm_release.metallb,
    helm_release.traefik,
    helm_release.cert_manager,
  ]
}

resource "time_sleep" "wait_kubernetes_step_2" {
  create_duration = "60s"

  triggers = {
    kubeapi_ip    = module.k3s_servers.kubeapi_ip
    kubeconf_host = module.k3s_servers.kubeconf.cluster.host
  }

  depends_on = [

  ]
}
