output "tools" {
  value = {
    cert_manager = {
      name      = helm_release.cert_manager.name
      namespace = helm_release.cert_manager.namespace
      versions = {
        app  = helm_release.cert_manager.metadata[0].app_version
        helm = helm_release.cert_manager.version
      }
    }
    coredns = {
      name      = helm_release.coredns.name
      namespace = helm_release.coredns.namespace
      versions = {
        app  = helm_release.coredns.metadata[0].app_version
        helm = helm_release.coredns.version
      }
    }
    traefik = {
      name      = helm_release.traefik.name
      namespace = helm_release.traefik.namespace
      versions = {
        app  = helm_release.traefik.metadata[0].app_version
        helm = helm_release.traefik.version
      }
    }
    metallb = {
      name      = helm_release.metallb.name
      namespace = helm_release.metallb.namespace
      versions = {
        app  = helm_release.metallb.metadata[0].app_version
        helm = helm_release.metallb.version
      }
    }
    loki_stack = {
      name      = helm_release.loki_stack.name
      namespace = helm_release.loki_stack.namespace
      versions = {
        app  = helm_release.loki_stack.metadata[0].app_version
        helm = helm_release.loki_stack.version
      }
    }
    metrics_server = {
      name      = helm_release.metrics_server.name
      namespace = helm_release.metrics_server.namespace
      versions = {
        app  = helm_release.metrics_server.metadata[0].app_version
        helm = helm_release.metrics_server.version
      }
    }
    kube_prometheus_stack = {
      name      = helm_release.kube_prometheus_stack.name
      namespace = helm_release.kube_prometheus_stack.namespace
      versions = {
        app  = helm_release.kube_prometheus_stack.metadata[0].app_version
        helm = helm_release.kube_prometheus_stack.version
      }
    }
    longhorn = {
      name      = helm_release.longhorn.name
      namespace = helm_release.longhorn.namespace
      versions = {
        app  = helm_release.longhorn.metadata[0].app_version
        helm = helm_release.longhorn.version
      }
    }
  }
}
