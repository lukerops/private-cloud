resource "random_id" "annotation_id" {
  byte_length = 2
  prefix      = "Terraform-"
}

resource "kubernetes_annotations" "nodes" {
  for_each = {
    for node in concat(local.server_nodes, local.agent_nodes) : node.name => node
    if can(node.annotations)
  }

  api_version   = "v1"
  kind          = "Node"
  field_manager = random_id.annotation_id.hex
  annotations   = each.value.annotations

  metadata {
    name = each.key
  }

  depends_on = [
    time_sleep.wait_k3s_agents,
  ]
}
