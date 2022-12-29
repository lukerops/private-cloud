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

output "token" {
  value     = var.token
  sensitive = true
}

output "kubeapi_ip" {
  value = var.kubeapi_ip
}
output "version" {
  value = local.version
}
