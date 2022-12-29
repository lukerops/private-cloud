data "http" "kube_vip_versions" {
  url = "https://api.github.com/repos/kube-vip/kube-vip/releases"
}

locals {
  versions = [
    for obj in jsondecode(data.http.kube_vip_versions.response_body) : obj.name
  ]
  version = var.versioning.version == null ? local.versions[0] : setintersection([var.versioning.version], local.versions)[0]

  envs = {
    vip_arp            = true
    port               = 6443
    vip_interface      = var.interface
    vip_cidr           = 32
    cp_enable          = true
    cp_namespace       = "kube-system"
    vip_ddns           = false
    svc_enable         = true
    vip_leaderelection = true
    vip_leaseduration  = 5
    vip_renewdeadline  = 3
    vip_retryperiod    = 1
    address            = var.address
    prometheus_server  = ":2112"
  }
}
