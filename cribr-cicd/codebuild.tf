# cribr-cicd\codebuild.tf

#############################################
# AWS CodeBuild Project
#############################################

locals {
  # Map of env var name => secret name in Secrets Manager
  secrets_map = {
    SUPABASE_KEY                  = "supabase-service-key"
    SUPABASE_ANON_KEY             = "supabase-anon-key"
    NEXT_PUBLIC_SUPABASE_ANON_KEY = "next-public-supabase-anon-key"
    GITHUB_TOKEN                  = "github-token"
    SONAR_TOKEN                   = "sonarqube-token"
    STRIPE_SECRET_KEY             = "stripe-secret-key"
    STRIPE_WEBHOOK_SECRET         = "stripe-webhook-secret"
    STRIPE_PUBLISHABLE_KEY        = "stripe-publishable-key"
    ASSEMBLYAI_API_KEY            = "assemblyai-api-key"
    TRANSCRIPT_IO_API_KEY         = "transcript-io-api-key"
    DUMPLINGAI_API_KEY            = "dumplingai-api-key"
    YOUTUBE_API_KEY               = "youtube-api-key"
    GOOGLE_CLIENT_ID              = "google-client-id"
    DOCKERHUB_USERNAME            = "dockerhub-credentials:DOCKERHUB_USERNAME"
    DOCKERHUB_PASSWORD            = "dockerhub-credentials:DOCKERHUB_PASSWORD"
  }
}

resource "aws_codebuild_project" "cribr_build" {
  name          = "${var.project_name}-build"
  description   = "CodeBuild project for ${var.project_name}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Plaintext env vars
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "SONAR_PROJECT_KEY"
      value = "darlingtonogbuefi_app-containerization"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ECR_REPO_URI"
      value = "493834426110.dkr.ecr.${var.aws_region}.amazonaws.com/cribr-app-repo"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = "cribr-ns"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "DEPLOYMENT_YAML"
      value = "cribr-cicd/deployment.yaml"
      type  = "PLAINTEXT"
    }

    # Dynamically add all secrets from Secrets Manager
    dynamic "environment_variable" {
      for_each = local.secrets_map
      content {
        name  = environment_variable.key
        value = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:cribr-${replace(environment_variable.value, ":", "-")}"
        type  = "SECRETS_MANAGER"
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "cribr-cicd/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
    }
  }
}
