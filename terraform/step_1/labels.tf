resource "random_id" "label_id" {
  byte_length = 2
  prefix      = "Terraform-"
}

resource "kubernetes_labels" "nodes" {
  for_each = {
    for node in concat(local.server_nodes, local.agent_nodes) : node.name => node
    if can(node.labels)
  }

  api_version   = "v1"
  kind          = "Node"
  field_manager = random_id.label_id.hex
  labels        = each.value.labels

  metadata {
    name = each.key
  }

  depends_on = [
    time_sleep.wait_k3s_agents,
  ]
}
