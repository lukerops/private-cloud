locals {
  channels = {
    for obj in jsondecode(data.http.channels.response_body).data : obj.id => obj.latest
    if contains(["stable", "latest", "testing"], obj.id)
  }
  versions = {
    for obj in jsondecode(data.http.channels.response_body).data : obj.id => obj.latest
    if !contains(["stable", "latest", "testing"], obj.id)
  }
  version = var.versioning.version != null ? local.versions[var.versioning.version] : local.channels[var.versioning.channel]

  kubeapi_ip = var.kubeapi_ip != null ? var.kubeapi_ip : local.server_nodes_hosts[0]
  envs = {
    "INSTALL_K3S_VERSION" = local.version,
    "K3S_URL"             = "https://${local.kubeapi_ip}:6443",
  }
  server_envs = {
    "K3S_KUBECONFIG_MODE" = "664",
    "K3S_TOKEN"           = random_password.server_token.result,
    "K3S_AGENT_TOKEN"     = random_password.agent_token.result,
  }
  agent_envs = {
    "K3S_TOKEN" = random_password.agent_token.result,
  }

  server_nodes_hosts = sort([
    for node in var.server_nodes : node.host
  ])
  server_nodes_envs = {
    for node in var.server_nodes : node.host => merge(local.envs, local.server_envs, {
      "K3S_NODE_NAME" = node.name
      }, index(local.server_nodes_hosts, node.host) > 0 ? {} : {
      "K3S_CLUSTER_INIT" = "true",
      "K3S_URL"          = null,
    })
  }
  server_nodes_commands = {
    for node in var.server_nodes : node.host => compact(flatten([
      "{ echo \"${node.sudo_password}\"; curl -sfL https://get.k3s.io; } |",
      [for k, v in local.server_nodes_envs[node.host] : "${k}=${v}" if v != null],
      "sudo -k -S sh -s - server",
      [for k, v in node.taints : "--node-taint=\"${k}=${v}\""],
      var.extra_commands.server,
    ]))
  }
  server_nodes = {
    for node in var.server_nodes : node.host => merge(node, {
      command = join(" ", local.server_nodes_commands[node.host])
    })
  }

  agent_nodes_hosts = sort([
    for node in var.agent_nodes : node.host
  ])
  agent_nodes_envs = {
    for node in var.agent_nodes : node.host => merge(local.envs, local.agent_envs, {
      "K3S_NODE_NAME" = node.name
    })
  }
  agent_nodes_commands = {
    for node in var.agent_nodes : node.host => flatten([
      "{ echo \"${node.sudo_password}\"; curl -sfL https://get.k3s.io; } |",
      [for k, v in local.agent_nodes_envs[node.host] : "${k}=${v}" if v != null],
      "sudo -k -S sh -s - agent",
      [for k, v in node.taints : "--node-taint=\"${k}=${v}\""],
      var.extra_commands.agent,
    ])
  }
  agent_nodes = {
    for node in var.agent_nodes : node.host => merge(node, {
      command = join(" ", local.agent_nodes_commands[node.host])
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
