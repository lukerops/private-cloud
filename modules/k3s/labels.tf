resource "time_sleep" "wait_server" {
  create_duration = "30s"

  triggers = merge(
    ssh_resource.server_create[local.server_nodes_hosts[0]].triggers,
    {
      host = local.server_nodes_hosts[0]
    },
  )
}

resource "kubernetes_labels" "label" {
  for_each = {
    for node in concat(var.server_nodes, var.agent_nodes) : node.name => node.labels
    if length(node.labels) > 0
  }

  api_version   = "v1"
  kind          = "Node"
  field_manager = "Terraform-${random_id.label_id.hex}"
  force         = true

  metadata {
    name = each.key
  }

  labels = each.value

  depends_on = [
    time_sleep.wait_server,
  ]
}
