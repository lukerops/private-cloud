data "http" "channels" {
  url = "https://update.k3s.io/v1-release/channels"
}

locals {
  channels = {
    for obj in jsondecode(data.http.channels.response_body).data : obj.id => obj.latest
    if contains(keys(obj), "latest") && contains(["stable", "latest", "testing"], obj.id)
  }
  versions = {
    for obj in jsondecode(data.http.channels.response_body).data : obj.id => obj.latest
    if contains(keys(obj), "latest") && !contains(["stable", "latest", "testing"], obj.id)
  }
  version = var.versioning.version != null ? local.versions[var.versioning.version] : local.channels[var.versioning.channel]

  kubeapi_ip = var.kubeapi_ip != null ? var.kubeapi_ip : local.nodes_hosts[0]
  envs = {
    "INSTALL_K3S_VERSION" = local.version,
    "K3S_URL"             = "https://${local.kubeapi_ip}:6443",
    "K3S_KUBECONFIG_MODE" = "644",
    "K3S_TOKEN"           = random_password.server_token.result,
    "K3S_AGENT_TOKEN"     = random_password.agent_token.result,
  }

  nodes_hosts = sort([
    for node in var.nodes : node.host
  ])
  nodes_envs = {
    for node in var.nodes : node.host => merge(local.envs, {
      "K3S_NODE_NAME" = node.name
      }, index(local.nodes_hosts, node.host) > 0 ? {} : {
      "K3S_CLUSTER_INIT" = "true",
      "K3S_URL"          = null,
    })
  }
  nodes_commands = {
    for node in var.nodes : node.host => compact(flatten([
      "curl -sfL https://get.k3s.io |",
      [for k, v in local.nodes_envs[node.host] : "${k}=\"${v}\"" if v != null],
      "sh -s - server",
      [for k, v in node.taints : "--node-taint=\"${k}=${v}\""],
      var.extra_commands,
    ]))
  }
  nodes = {
    for node in var.nodes : node.host => merge(node, {
      command = join(" ", local.nodes_commands[node.host])
    })
  }

  kubeconf_raw = yamldecode(ssh_sensitive_resource.kubeconf.result)
  kubeconf = {
    cluster = {
      host           = "https://${local.kubeapi_ip}:6443"
      ca_certificate = base64decode(local.kubeconf_raw.clusters[0].cluster.certificate-authority-data)
    }
    client = {
      certificate = base64decode(local.kubeconf_raw.users[0].user.client-certificate-data)
      key         = base64decode(local.kubeconf_raw.users[0].user.client-key-data)
    }
  }
}
