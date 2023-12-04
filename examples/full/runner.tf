# create runner
resource "kubernetes_service_account" "runner" {
  metadata {
    name      = "test-runner"
    namespace = module.actions_runner_controller.namespace
  }
  secret {
    name = kubernetes_secret.runner.metadata[0].name
  }
}

resource "kubernetes_secret" "runner" {
  metadata {
    name      = "test-runner"
    namespace = module.actions_runner_controller.namespace
  }
}

resource "kubernetes_role" "runner" {
  metadata {
    name      = "test-runner"
    namespace = module.actions_runner_controller.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["get", "create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "create", "delete"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "get", "list"]
  }
}

resource "kubernetes_role_binding" "runner" {
  metadata {
    name      = "test-runner"
    namespace = module.actions_runner_controller.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "test-runner"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "test-runner"
    namespace = module.actions_runner_controller.namespace
  }
}

resource "kubectl_manifest" "runner" {
  yaml_body = yamlencode({
    apiVersion = "actions.summerwind.dev/v1alpha1"
    kind       = "RunnerDeployment"
    metadata = {
      name      = "test-runner"
      namespace = module.actions_runner_controller.namespace
    }
    spec = {
      replicas = 2
      template = {
        spec = {
          repository         = "infinite-automations/terraform-helm-github-actions-runner-controller"
          labels             = var.labels
          serviceAccountName = kubernetes_service_account.runner.metadata[0].name
          containerMode      = "kubernetes"
          workVolumeClaimTemplate = {
            storageClassName = "standard"
            accessModes = [
              "ReadWriteOnce"
            ]
            resources = {
              requests = {
                storage = "100Mi"
              }
            }
          }
        }
      }
    }
  })
  depends_on = [
    module.actions_runner_controller,
    kubernetes_service_account.runner
  ]
}
