resource "kubernetes_daemonset" "kube_vip" {
  metadata {
    name      = "kube-vip-ds"
    namespace = local.envs.cp_namespace
    labels = {
      "app.kubernetes.io/name"    = "kube-vip-ds"
      "app.kubernetes.io/version" = local.version
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "kube-vip-ds"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "kube-vip-ds"
          "app.kubernetes.io/version" = local.version
        }
      }

      spec {
        host_network         = true
        service_account_name = kubernetes_service_account.kube_vip.metadata[0].name

        container {
          name = "kube-vip"

          image             = "ghcr.io/kube-vip/kube-vip:${local.version}"
          image_pull_policy = "Always"
          args              = ["manager"]

          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }

          dynamic "env" {
            for_each = local.envs
            content {
              name  = env.key
              value = env.value
            }
          }
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/master"
                  operator = "Exists"
                }
              }

              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "Exists"
                }
              }
            }
          }
        }

        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }

        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
      }
    }
  }
}
