resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "20.8.0"

  namespace        = "traefik"
  create_namespace = true

  # Não pode esperar porque as configurações do load-balance acontecem
  # em outro passo, então, vai ficar como pending até lá.
  wait = false

  values = [
    <<-EOT
    deployment:
      podAnnotations:
        linkerd.io/inject: ingress
    additionalArguments:
      - --entryPoints.web.http.redirections.entryPoint.to=websecure
      - --entryPoints.web.http.redirections.entryPoint.scheme=https
    service:
      annotations:
        metallb.universe.tf/address-pool: cloud-provider
    ingressRoute:
      dashboard:
        enabled: false
    ports:
      web:
        port: 80
      websecure:
        # asDefault: true
        port: 443
    EOT
  ]

  depends_on = [
    module.k3s_agents,
  ]
}
