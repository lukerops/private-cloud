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

  agent_envs = {
    "INSTALL_K3S_VERSION" = local.version,
    "K3S_URL"             = "https://${var.kubeapi_ip}:6443",
    "K3S_TOKEN"           = var.token,
  }

  nodes_hosts = sort([
    for node in var.nodes : node.host
  ])
  nodes_envs = {
    for node in var.nodes : node.host => merge(local.agent_envs, {
      "K3S_NODE_NAME" = node.name
    })
  }
  nodes_commands = {
    for node in var.nodes : node.host => flatten([
      "curl -sfL https://get.k3s.io |",
      [for k, v in local.nodes_envs[node.host] : "${k}=\"${v}\"" if v != null],
      "sh -s - agent",
      [for k, v in node.taints : "--node-taint=\"${k}=${v}\""],
      var.extra_commands,
    ])
  }
  nodes = {
    for node in var.nodes : node.host => merge(node, {
      command = join(" ", local.nodes_commands[node.host])
    })
  }
}
