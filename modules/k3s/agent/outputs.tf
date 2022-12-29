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

output "kubeconf" {
  value     = var.kubeconf
  sensitive = true

  depends_on = [
    kubernetes_labels.label,
  ]
}

output "version" {
  value = local.version
}
