resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.4.0"

  namespace        = "longhorn-system"
  create_namespace = true
  wait_for_jobs    = true

  # Não pode injetar o linkerd no longhorn
  # https://github.com/longhorn/longhorn/issues/3809
  values = [
    <<-EOT
    ingress:
      enabled: true
      ingressClassName: traefik
      host: longhorn.storage.k8s.homecluster.local
      tls: true
      annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
        traefik.ingress.kubernetes.io/router.tls: "true"
        traefik.ingress.kubernetes.io/router.middlewares: longhorn-system-longhorn-frontend-header@kubernetescrd
        cert-manager.io/cluster-issuer: selfsigned
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
}
