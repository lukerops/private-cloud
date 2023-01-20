# resource "random_id" "annotation_filed_manager_id" {
#   byte_length = 2
# }
#
# resource "kubernetes_annotations" "kube_system_namespace" {
#   api_version   = "v1"
#   kind          = "Namespace"
#   field_manager = "Terraform-${random_id.annotation_filed_manager_id.hex}"
#
#   metadata {
#     name = "kube-system"
#   }
#
#   annotations = {
#     "linkerd.io/inject" = "enabled"
#   }
# }
#
# resource "kubernetes_annotations" "traefik_namespace" {
#   api_version   = "v1"
#   kind          = "Namespace"
#   field_manager = "Terraform-${random_id.annotation_filed_manager_id.hex}"
#
#   metadata {
#     name = helm_release.traefik.namespace
#   }
#
#   annotations = {
#     "linkerd.io/inject" = "enabled"
#   }
# }
#
# resource "kubernetes_annotations" "metallb_namespace" {
#   api_version   = "v1"
#   kind          = "Namespace"
#   field_manager = "Terraform-${random_id.annotation_filed_manager_id.hex}"
#
#   metadata {
#     name = helm_release.metallb.namespace
#   }
#
#   annotations = {
#     "linkerd.io/inject" = "enabled"
#   }
# }
#
# resource "kubernetes_annotations" "loki_namespace" {
#   api_version   = "v1"
#   kind          = "Namespace"
#   field_manager = "Terraform-${random_id.annotation_filed_manager_id.hex}"
#
#   metadata {
#     name = helm_release.loki_stack.namespace
#   }
#
#   annotations = {
#     "linkerd.io/inject" = "enabled"
#   }
# }
#
# resource "kubernetes_annotations" "cert_manager_namespace" {
#   api_version   = "v1"
#   kind          = "Namespace"
#   field_manager = "Terraform-${random_id.annotation_filed_manager_id.hex}"
#
#   metadata {
#     name = helm_release.cert_manager.namespace
#   }
#
#   annotations = {
#     "linkerd.io/inject" = "enabled"
#   }
# }
