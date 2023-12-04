locals {
  namespace = var.create_namespace ? kubernetes_namespace.this.0.metadata.0.name : data.kubernetes_namespace.this.0.metadata.0.name
}

data "kubernetes_namespace" "this" {
  count = var.create_namespace ? 0 : 1
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "this" {
  metadata {
    name      = var.kubernetes_secret_name
    namespace = local.namespace
  }

  data = {
    github_app_id              = var.github_app_id
    github_app_installation_id = var.github_app_install_id
    github_app_private_key     = var.github_app_private_key
  }
}

resource "helm_release" "this" {
  name       = var.helm_deployment_name
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = var.helm_chart_version
  namespace  = local.namespace

  atomic  = var.atomic
  timeout = var.timeout

  values = [yamlencode({
    replicaCount = var.replicas
    authSecret = {
      name   = kubernetes_secret.this.metadata.0.name
      create = false
    }
    rbac = {
      allowGrantingKubernetesContainerModePermissions = var.allow_granting_container_mode_permissions
    }
  })]
}
