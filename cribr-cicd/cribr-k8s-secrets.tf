# cribr-cicd\cribr-k8s-secrets.tf

#############################################
# Kubernetes Secret from AWS Secrets Manager
# All secrets combined into one
#############################################

variable "k8s_namespace" {
  default = "cribr-ns"
}

variable "k8s_secrets" {
  type = map(string)
  default = {
    NEXT_PUBLIC_SUPABASE_ANON_KEY   = "cribr-next-public-supabase-anon-key"
    SUPABASE_SERVICE_KEY             = "cribr-supabase-service-key"
    STRIPE_SECRET_KEY                = "cribr-stripe-secret-key"
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY = "cribr-stripe-publishable-key"
    STRIPE_WEBHOOK_SECRET            = "cribr-stripe-webhook-secret"
    DUMPLINGAI_API_KEY               = "cribr-dumplingai-api-key"
    ASSEMBLYAI_API_KEY               = "cribr-assemblyai-api-key"
    TRANSCRIPT_IO_API_KEY            = "cribr-transcript-io-api-key"
    YOUTUBE_API_KEY                  = "cribr-youtube-api-key"
    NEXT_PUBLIC_GOOGLE_CLIENT_ID     = "cribr-google-client-id"
  }
}

# Fetch each secret from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "secret" {
  for_each  = var.k8s_secrets
  secret_id = each.value
}

# Create a single Kubernetes secret containing all keys
resource "kubernetes_secret" "cribr_secrets_combined" {
  metadata {
    name      = "cribr-secrets"
    namespace = var.k8s_namespace
  }

  data = {
    for k in keys(var.k8s_secrets) :
    k => data.aws_secretsmanager_secret_version.secret[k].secret_string
  }

  type = "Opaque"
}
