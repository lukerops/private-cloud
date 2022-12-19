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
}
