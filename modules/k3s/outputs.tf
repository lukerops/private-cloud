output "kubeconf" {
  value = local.kubeconf
  depends_on = [
    kubernetes_labels.label,
  ]
}

output "server_nodes" {
  value = { for node in var.server_nodes : node.host => node }
}

output "agent_nodes" {
  value = { for node in var.agent_nodes : node.host => node }
}

output "extra_commands" {
  value = var.extra_commands
}

output "version" {
  value = local.version
}

output "kubeapi_ip" {
  value = local.kubeapi_ip
}
