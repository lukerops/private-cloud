terraform {
  required_version = ">= 1.3.0, < 1.4.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1, < 3.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0, < 3.0.0"
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
  alias = "step_1"

  client_certificate     = module.k3s_servers.kubeconf.client.certificate
  client_key             = module.k3s_servers.kubeconf.client.key
  cluster_ca_certificate = module.k3s_servers.kubeconf.cluster.ca_certificate
  host                   = "https://${sort([for node in module.k3s_servers.nodes : node.host])[0]}:6443"
}

provider "helm" {
  alias = "step_1"

  kubernetes {
    client_certificate     = module.k3s_servers.kubeconf.client.certificate
    client_key             = module.k3s_servers.kubeconf.client.key
    cluster_ca_certificate = module.k3s_servers.kubeconf.cluster.ca_certificate
    host                   = time_sleep.wait_kubernetes_step_1.triggers.kubeconf_host
  }
}

provider "kubernetes" {
  alias = "step_2"

  client_certificate     = module.k3s_servers.kubeconf.client.certificate
  client_key             = module.k3s_servers.kubeconf.client.key
  cluster_ca_certificate = module.k3s_servers.kubeconf.cluster.ca_certificate
  host                   = time_sleep.wait_helm_step_1.triggers.kubeconf_host
}

provider "helm" {
  alias = "step_2"

  kubernetes {
    client_certificate     = module.k3s_servers.kubeconf.client.certificate
    client_key             = module.k3s_servers.kubeconf.client.key
    cluster_ca_certificate = module.k3s_servers.kubeconf.cluster.ca_certificate
    host                   = time_sleep.wait_kubernetes_step_2.triggers.kubeconf_host
  }
}
