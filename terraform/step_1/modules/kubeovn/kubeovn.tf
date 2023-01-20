data "http" "kubeovn_versions" {
  url = "https://api.github.com/repos/kubeovn/kube-ovn/releases"
}

locals {
  versions = [
    for obj in jsondecode(data.http.kubeovn_versions.response_body) : obj.tag_name
  ]
  version = var.versioning.version == null ? local.versions[0] : tolist(setintersection([var.versioning.version], local.versions))[0]

  script_url_base = "https://raw.githubusercontent.com/kubeovn/kube-ovn/${local.version}/dist/images"
}

resource "ssh_resource" "install" {
  when         = "create"
  host         = var.node.host
  user         = var.node.user
  bastion_host = var.node.bastion
  agent        = true

  timeout = var.timeout
  commands = [
    join(" ", [
      "/tmp/kubeovn_tf.sh",
      "${local.script_url_base}/install.sh",
      var.node_label,
      var.pod_cidr,
      cidrhost(var.pod_cidr, 1),
      var.svc_cidr,
      var.join_cidr,
      var.tunnel_type,
    ])
  ]

  file {
    destination = "/tmp/kubeovn_tf.sh"
    permissions = "0744"
    content     = <<-EOT
    #!/usr/bin/env bash
    set -euo pipefail

    URL=$1
    LABEL=$2
    POD=$3
    POD_GATEWAY=$4
    SVC=$5
    JOIN=$6
    TUNNEL=$7

    mkdir -p /tmp/kubeovn
    cd /tmp/kubeovn
    curl -sfL $URL | sed \
      -e "s|^LABEL=\".*\"|LABEL=\"$LABEL\"|" \
      -e "s|^POD_CIDR=\".*\"|POD_CIDR=\"$POD\"|" \
      -e "s|^POD_GATEWAY=\".*\"|POD_GATEWAY=\"$POD_GATEWAY\"|" \
      -e "s|^SVC_CIDR=\".*\"|SVC_CIDR=\"$SVC\"|" \
      -e "s|^JOIN_CIDR=\".*\"|JOIN_CIDR=\"$JOIN\"|" \
      -e "s|^TUNNEL_TYPE=\".*\"|TUNNEL_TYPE=\"$TUNNEL\"|" \
    | sudo bash - || true

    cd /tmp
    rm -rf /tmp/kubeovn
    rm /tmp/kubeovn_tf.sh
    EOT
  }

  triggers = {
    version = local.version
  }
}

resource "ssh_resource" "uninstall" {
  when         = "destroy"
  host         = var.node.host
  user         = var.node.user
  bastion_host = var.node.bastion
  agent        = true

  timeout = var.timeout
  commands = [
    "curl -sfL ${local.script_url_base}/cleanup.sh | sudo bash -"
  ]

  lifecycle {
    replace_triggered_by = [
      ssh_resource.install.id,
    ]
  }
}
