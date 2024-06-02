<!-- BEGIN_TF_DOCS -->


## 1. Setup Cert Manager

```hcl
# create namespace for cert mananger
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    labels = {
      "name" = "cert-manager"
    }
    name = "cert-manager"
  }
}

# install cert-manager helm chart using terraform
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.12.3"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  atomic     = true
  timeout    = 600
  set {
    name  = "installCRDs"
    value = "true"
  }
}
```

## 2. Setup Agents Runner Controller

```hcl
# setup actions-runner-controller
module "actions_runner_controller" {
  source                                    = "../.."
  namespace                                 = "github-actions-runner-controller"
  create_namespace                          = true
  allow_granting_container_mode_permissions = false
  github_app_id                             = var.github_app_id
  github_app_install_id                     = var.github_app_install_id
  github_app_private_key                    = var.github_app_private_key
  kubernetes_secret_name                    = "github-auth-secret"
  helm_deployment_name                      = "actions-runner-controller"
  helm_chart_version                        = "0.23.5"
  replicas                                  = 1
  atomic                                    = true
  timeout                                   = 600
  depends_on = [
    helm_release.cert_manager
  ]
}
```

## 3. Setup Runner

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.11.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.12.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.25.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.runner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.runner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | GitHub App ID | `string` | n/a | yes |
| <a name="input_github_app_install_id"></a> [github\_app\_install\_id](#input\_github\_app\_install\_id) | GitHub App Install ID | `string` | n/a | yes |
| <a name="input_github_app_private_key"></a> [github\_app\_private\_key](#input\_github\_app\_private\_key) | GitHub App Private Key | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels for the runner | `list(string)` | n/a | yes |




<!-- END_TF_DOCS -->