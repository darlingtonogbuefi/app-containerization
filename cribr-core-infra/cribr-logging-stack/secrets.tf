#############################################
# AWS Secrets Manager for Elasticsearch password
#############################################

resource "aws_secretsmanager_secret" "elastic_password" {
  name        = var.elastic_secret_name
  description = "Elasticsearch password for logging stack"
}

resource "aws_secretsmanager_secret_version" "elastic_password_version" {
  secret_id     = aws_secretsmanager_secret.elastic_password.id
  secret_string = jsonencode({
    elastic = var.elastic_password
  })
}

# Fetch the secret for use in Helm charts
data "aws_secretsmanager_secret_version" "elastic_password" {
  secret_id = aws_secretsmanager_secret.elastic_password.id
}
