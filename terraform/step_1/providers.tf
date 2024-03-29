terraform {
  required_version = ">= 1.3.0, < 1.4.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1, < 3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3, < 4.0.0"
    }

    ssh = {
      source  = "loafoe/ssh"
      version = ">= 2.2.1, < 3.0.0"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.1.0, < 4.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}

provider "kubernetes" {
  client_certificate     = module.k3s_servers.kubeconf.client.certificate
  client_key             = module.k3s_servers.kubeconf.client.key
  cluster_ca_certificate = module.k3s_servers.kubeconf.cluster.ca_certificate
  host                   = "https://${sort([for node in module.k3s_servers.nodes : node.host])[0]}:6443"
}
