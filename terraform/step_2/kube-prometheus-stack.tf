resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "43.3.0"

  namespace        = "monitoring"
  create_namespace = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    alertmanager:
      alertmanagerSpec:
        podMetadata:
          annotations:
            linkerd.io/inject: enabled
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
          traefik.ingress.kubernetes.io/router.middlewares: monitoring-kube-prometheus-stack-alertmanager-header@kubernetescrd
          cert-manager.io/cluster-issuer: selfsigned
        hosts:
          - alertmanager.monitoring.k8s.homecluster.local
        tls:
          - secretName: alertmanager-tls
            hosts:
              - alertmanager.monitoring.k8s.homecluster.local

    grafana:
      podAnnotations:
        linkerd.io/inject: enabled
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
          traefik.ingress.kubernetes.io/router.middlewares: monitoring-kube-prometheus-stack-grafana-header@kubernetescrd
          cert-manager.io/cluster-issuer: selfsigned
        hosts:
          - grafana.monitoring.k8s.homecluster.local
        tls:
          - secretName: grafana-tls
            hosts:
              - grafana.monitoring.k8s.homecluster.local

    coreDns:
      service:
        selector:
          app.kubernetes.io/instance: coredns
          app.kubernetes.io/name: coredns
          k8s-app: coredns

    prometheusOperator:
      resources:
        limits:
          cpu: 200m
          memory: 200Mi
        requests:
          cpu: 100m
          memory: 100Mi

    prometheus:
      prometheusSpec:
        serviceMonitorSelectorNilUsesHelmValues: false
        podMonitorSelectorNilUsesHelmValues: false
        podMetadata:
          annotations:
            linkerd.io/inject: enabled
        storageSpec:
          volumeClaimTemplate:
            spec:
              # storageClassName: ceph-filesystem
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi
    EOT
  ]

  depends_on = [
    helm_release.longhorn,
  ]
}
