variable "namespace" {
  type        = string
  description = "The namespace to deploy the runner controller into"
  default     = "github-actions-runner-controller"
}

variable "create_namespace" {
  type        = bool
  description = "If true, the namespace will be created"
  default     = true
}

variable "allow_granting_container_mode_permissions" {
  type        = bool
  description = "If true, the runner controller will be allowed to grant container mode permissions"
  default     = false
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID"
  sensitive   = true
}

variable "github_app_install_id" {
  type        = string
  description = "GitHub App Install ID"
  sensitive   = true
}

variable "github_app_private_key" {
  type        = string
  description = "GitHub App Private Key"
  sensitive   = true
}

variable "kubernetes_secret_name" {
  type        = string
  description = "The name of the secret to create"
  default     = "github-auth-secret"
}

variable "helm_deployment_name" {
  type        = string
  description = "The name of the helm deployment"
  default     = "actions-runner-controller"
}

variable "helm_chart_version" {
  type        = string
  description = "The version of the helm chart to deploy"
  default     = "0.23.5"
}

variable "replicas" {
  type        = number
  description = "The number of replicas for the runner controller"
  default     = 3
}

variable "atomic" {
  type        = bool
  description = "If true, installation process purges chart on fail. If false, installation process deletes resources created by chart, but not purge them"
  default     = true
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for helm deployment operation (like Jobs for hooks)"
  default     = 600
}
