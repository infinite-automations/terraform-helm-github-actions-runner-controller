output "namespace" {
  value       = local.namespace
  description = "The namespace runner controller was deployed into"
}

output "secret_name" {
  value       = kubernetes_secret.this.metadata.0.name
  description = "The name of the secret created"
}

output "helm_deployment_name" {
  value       = helm_release.this.metadata.0.name
  description = "The name of the helm deployment"
}
