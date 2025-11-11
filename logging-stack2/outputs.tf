# cribr-core-infra\cribr-logging-stack2\outputs.tf

#############################################
# Outputs for Verification
#############################################

output "elastic_secret_arn" {
  description = "ARN of Elastic API Secret stored in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.elastic_api_secret.arn
}

output "elastic_api_key_masked" {
  description = "Elastic API Key (partially masked)"
  value       = substr(var.elastic_api_key, 0, 20)
  sensitive   = true
}

output "elastic_agent_status_note" {
  description = "Instructions after deployment"
  value       = <<EOT
Elastic Agent Helm chart deployed successfully.

Verify:
- Kibana → Fleet → Agents
- kubectl get pods -n elastic-system

Elastic configuration secret:
AWS Secrets Manager → elastic-api-config
EOT
}
