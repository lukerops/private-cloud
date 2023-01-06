data "http" "kubeovn_versions" {
  url = "https://api.github.com/repos/kubeovn/kube-ovn/releases"
}

locals {
  versions = [
    for obj in jsondecode(data.http.kubeovn_versions.response_body) : obj.tag_name
  ]
  version = var.versioning.version == null ? local.versions[0] : tolist(setintersection([var.versioning.version], local.versions))[0]

  script_url = "https://raw.githubusercontent.com/kubeovn/kube-ovn/${local.version}/dist/images/install.sh"
}

resource "ssh_resource" "server_create" {
  when         = "create"
  host         = var.node.host
  user         = var.node.user
  bastion_host = var.node.bastion
  agent        = true

  timeout  = var.timeout
  commands = [
    "export VERSION=\"${local.version}\"",
    "export POD_CIDR=\"${var.pod_cidr}\"",
    "export SVC_CIDR=\"${var.svc_cidr}\"",
    "export JOIN_CIDR=\"${var.join_cidr}\"",
    "export LABEL=\"${var.node_label}\"",
    "export TUNNEL_TYPE=\"${var.tunnel_type}\"",
    "curl -sfL https://get.k3s.io | sh -s -",
  ]

  triggers = {
    version = local.version
  }
}
