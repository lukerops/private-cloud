resource "time_sleep" "wait_server" {
  create_duration = "10s"

  triggers = merge(
    ssh_resource.server_create[local.nodes_hosts[0]].triggers,
    {
      host       = local.nodes_hosts[0],
      kubeapi_ip = local.kubeapi_ip,
    },
  )
}

resource "ssh_sensitive_resource" "kubeconf" {
  when         = "create"
  host         = local.nodes_hosts[0]
  user         = values(local.nodes)[0].user
  bastion_host = values(local.nodes)[0].bastion
  agent        = true

  timeout = var.timeout
  commands = [
    "cat /etc/rancher/k3s/k3s.yaml",
  ]

  depends_on = [
    time_sleep.wait_server,
  ]

  lifecycle {
    replace_triggered_by = [
      ssh_resource.server_create,
    ]
  }
}
