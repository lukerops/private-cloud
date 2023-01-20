resource "kubernetes_manifest" "grafana_traefik_middleware" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
      name: kube-prometheus-stack-grafana-header
      namespace: ${data.terraform_remote_state.step_1.outputs.tools.kube_prometheus_stack.namespace}
    spec:
      headers:
        customRequestHeaders:
          l5d-dst-override: "kube-prometheus-stack-grafana.${data.terraform_remote_state.step_1.outputs.tools.kube_prometheus_stack.namespace}.svc.cluster.local:80"
    EOT
  )
}

resource "kubernetes_manifest" "alertmanager_traefik_middleware" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
      name: kube-prometheus-stack-alertmanager-header
      namespace: ${data.terraform_remote_state.step_1.outputs.tools.kube_prometheus_stack.namespace}
    spec:
      headers:
        customRequestHeaders:
          l5d-dst-override: "kube-prometheus-stack-alertmanager.${data.terraform_remote_state.step_1.outputs.tools.kube_prometheus_stack.namespace}.svc.cluster.local:9093"
    EOT
  )
}
