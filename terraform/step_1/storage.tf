resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.4.0"

  namespace        = "longhorn-system"
  create_namespace = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    longhornManager:
      nodeSelector:
        node-role.kubernetes.io/storage: "true"
    persistence:
      defaultDataLocality: best-effort
    defaultSettings:
      defaultClassReplicaCount: 3
      createDefaultDiskLabeledNodes: true
      defaultDataLocality: best-effort
      replicaSoftAntiAffinity: true
      replicaAutoBalance: best-effort
    EOT
  ]

  depends_on = [
    kubernetes_labels.nodes,
    kubernetes_annotations.nodes,
  ]
}
