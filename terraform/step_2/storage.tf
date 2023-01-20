resource "kubernetes_manifest" "longhorn_traefik_middleware" {
  manifest = yamldecode(
    <<-EOT
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
      name: longhorn-frontend-header
      namespace: ${data.terraform_remote_state.step_1.outputs.tools.longhorn.namespace}
    spec:
      headers:
        customRequestHeaders:
          l5d-dst-override: "longhorn-frontend.${data.terraform_remote_state.step_1.outputs.tools.longhorn.namespace}.svc.cluster.local:80"
    EOT
  )
}
