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
  client_certificate     = data.terraform_remote_state.step_1.outputs.kubeconf.client.certificate
  client_key             = data.terraform_remote_state.step_1.outputs.kubeconf.client.key
  cluster_ca_certificate = data.terraform_remote_state.step_1.outputs.kubeconf.cluster.ca_certificate
  host                   = data.terraform_remote_state.step_1.outputs.kubeconf.cluster.host
}

provider "helm" {
  kubernetes {
    client_certificate     = data.terraform_remote_state.step_1.outputs.kubeconf.client.certificate
    client_key             = data.terraform_remote_state.step_1.outputs.kubeconf.client.key
    cluster_ca_certificate = data.terraform_remote_state.step_1.outputs.kubeconf.cluster.ca_certificate
    host                   = data.terraform_remote_state.step_1.outputs.kubeconf.cluster.host
  }
}
