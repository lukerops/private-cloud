resource "helm_release" "kube_prometheus" {
  provider = helm.step_1

  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "43.3.0"

  namespace        = "monitoring"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    alertmanager:
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
          cert-manager.io/cluster-issuer: selfsigned
        hosts:
          - alertmanager.monitoring.k8s.homecluster.local
        tls:
          - secretName: alertmanager-tls
            hosts:
              - alertmanager.monitoring.k8s.homecluster.local

    grafana:
      ingress:
        enabled: true
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
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
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 5Gi
    EOT
  ]
}
