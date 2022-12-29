output "versioning" {
  value = var.versioning
}

output "timeout" {
  value = var.timeout
}

output "nodes" {
  value = var.nodes
}

output "extra_commands" {
  value = var.extra_commands
}

output "kubeapi_ip" {
  value = local.kubeapi_ip
}

output "kubeconf" {
  value     = local.kubeconf
  sensitive = true

  depends_on = [
    ssh_resource.server_destroy,
  ]
}

output "version" {
  value = local.version
}

output "agent_token" {
  value     = random_password.agent_token.result
  sensitive = true
}
