output "kubeconf" {
  value = local.kubeconf
  depends_on = [
    kubernetes_labels.label,
  ]
}

output "version" {
  value = local.version
}

output "kubeapi_ip" {
  value = local.kubeapi_ip
}
