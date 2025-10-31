# cribr-cicd\cribr-k8s-secrets.tf

#############################################
# Kubernetes Secret from AWS Secrets Manager
# All secrets combined into one
#############################################

variable "k8s_namespace" {
  type    = string
  default = "cribr-ns"
}

variable "k8s_secrets" {
  type = map(string)
  default = {
    cribr-supabase-anon-key             = "cribr-supabase-anon-key"
    cribr-stripe-webhook-secret         = "cribr-stripe-webhook-secret"
    cribr-youtube-api-key               = "cribr-youtube-api-key"
    cribr-next-public-supabase-anon-key = "cribr-next-public-supabase-anon-key"
    cribr-assemblyai-api-key            = "cribr-assemblyai-api-key"
    cribr-stripe-secret-key             = "cribr-stripe-secret-key"
    cribr-dumplingai-api-key            = "cribr-dumplingai-api-key"
    cribr-google-client-id              = "cribr-google-client-id"
    cribr-stripe-publishable-key        = "cribr-stripe-publishable-key"
    cribr-transcript-io-api-key         = "cribr-transcript-io-api-key"
    cribr-supabase-service-key          = "cribr-supabase-service-key"
  }
}

# Fetch secrets from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "secret" {
  for_each  = var.k8s_secrets
  secret_id = each.value
}

# Combine all secrets into a single Kubernetes secret
resource "kubernetes_secret" "cribr_secrets_combined" {
  metadata {
    name      = "cribr-secrets"
    namespace = var.k8s_namespace
  }

  data = { 
    for k, v in var.k8s_secrets :
    k => data.aws_secretsmanager_secret_version.secret[v].secret_string
  }

  type = "Opaque"
}
