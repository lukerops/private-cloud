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
          ingress.kubernetes.io/custom-request-headers: l5d-dst-override:kube-prometheus-grafana.monitoring.svc.cluster.local:80
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
              # storageClassName: ceph-filesystem
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi
    EOT
  ]

  depends_on = [
    module.k3s_agents,
    helm_release.longhorn,
  ]
}
