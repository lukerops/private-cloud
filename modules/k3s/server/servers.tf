resource "ssh_resource" "server_create" {
  for_each = local.nodes

  when         = "create"
  host         = each.key
  user         = each.value.user
  bastion_host = each.value.bastion
  agent        = true

  timeout  = var.timeout
  commands = [each.value.command]

  triggers = {
    for k, v in [each.value.user, each.value.bastion] : k => v
  }
}

resource "ssh_resource" "server_destroy" {
  for_each = local.nodes

  when         = "destroy"
  host         = each.key
  user         = each.value.user
  bastion_host = each.value.bastion
  agent        = true

  timeout = var.timeout
  commands = [
    "/usr/local/bin/k3s-uninstall.sh",
  ]

  lifecycle {
    replace_triggered_by = [
      ssh_resource.server_create[each.key].id,
    ]
  }
}
