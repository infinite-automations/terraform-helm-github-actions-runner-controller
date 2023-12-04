# terraform-helm-github-actions-runner-controller

[![Test & Release](https://github.com/infinite-automations/terraform-helm-github-actions-runner-controller/actions/workflows/test-and-release.yml/badge.svg)](https://github.com/infinite-automations/terraform-helm-github-actions-runner-controller/actions/workflows/test-and-release.yml)

Setup the GitHub Actions Runner Controller (ARC) in an existing kubernetes cluster.

<!-- BEGIN_TF_DOCS -->


## Module Usage

```hcl
# setup actions-runner-controller
module "actions-runner-controller" {
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

## Requirements

| Name                                                                         | Version   |
| ---------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 0.13   |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                   | >= 2.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23.0 |

## Providers

| Name                                                                   | Version   |
| ---------------------------------------------------------------------- | --------- |
| <a name="provider_helm"></a> [helm](#provider\_helm)                   | >= 2.11.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23.0 |

## Resources

| Name                                                                                                                      | Type     |
| ------------------------------------------------------------------------------------------------------------------------- | -------- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                 | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret)       | resource |

## Inputs

| Name                                                                                                                                                                  | Description                                                                                                                               | Type     | Default                              | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------ | :------: |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id)                                                                                         | GitHub App ID                                                                                                                             | `string` | n/a                                  |   yes    |
| <a name="input_github_app_install_id"></a> [github\_app\_install\_id](#input\_github\_app\_install\_id)                                                               | GitHub App Install ID                                                                                                                     | `string` | n/a                                  |   yes    |
| <a name="input_github_app_private_key"></a> [github\_app\_private\_key](#input\_github\_app\_private\_key)                                                            | GitHub App Private Key                                                                                                                    | `string` | n/a                                  |   yes    |
| <a name="input_allow_granting_container_mode_permissions"></a> [allow\_granting\_container\_mode\_permissions](#input\_allow\_granting\_container\_mode\_permissions) | If true, the runner controller will be allowed to grant container mode permissions                                                        | `bool`   | `false`                              |    no    |
| <a name="input_atomic"></a> [atomic](#input\_atomic)                                                                                                                  | If true, installation process purges chart on fail. If false, installation process deletes resources created by chart, but not purge them | `bool`   | `true`                               |    no    |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace)                                                                                  | If true, the namespace will be created                                                                                                    | `bool`   | `true`                               |    no    |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version)                                                                          | The version of the helm chart to deploy                                                                                                   | `string` | `"0.23.5"`                           |    no    |
| <a name="input_helm_deployment_name"></a> [helm\_deployment\_name](#input\_helm\_deployment\_name)                                                                    | The name of the helm deployment                                                                                                           | `string` | `"actions-runner-controller"`        |    no    |
| <a name="input_kubernetes_secret_name"></a> [kubernetes\_secret\_name](#input\_kubernetes\_secret\_name)                                                              | The name of the secret to create                                                                                                          | `string` | `"github-auth-secret"`               |    no    |
| <a name="input_namespace"></a> [namespace](#input\_namespace)                                                                                                         | The namespace to deploy the runner controller into                                                                                        | `string` | `"github-actions-runner-controller"` |    no    |
| <a name="input_replicas"></a> [replicas](#input\_replicas)                                                                                                            | The number of replicas for the runner controller                                                                                          | `number` | `3`                                  |    no    |
| <a name="input_timeout"></a> [timeout](#input\_timeout)                                                                                                               | Time in seconds to wait for helm deployment operation (like Jobs for hooks)                                                               | `number` | `600`                                |    no    |

## Outputs

| Name                                                                                                 | Description                                       |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| <a name="output_helm_deployment_name"></a> [helm\_deployment\_name](#output\_helm\_deployment\_name) | The name of the helm deployment                   |
| <a name="output_namespace"></a> [namespace](#output\_namespace)                                      | The namespace runner controller was deployed into |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name)                              | The name of the secret created                    |


<!-- END_TF_DOCS -->