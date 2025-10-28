#   cribr-cicd\codebuild.tf

#############################################
# AWS CodeBuild Project
#############################################

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

    # Environment variables for your build
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
      name  = "SONAR_TOKEN"
      value = "arn:aws:secretsmanager:us-east-1:493834426110:secret:cribr-sonarqube-token-OKMk3p"
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "DOCKERHUB_USERNAME"
      value = "arn:aws:secretsmanager:us-east-1:493834426110:secret:cribr-dockerhub-credentials-0e7HCI:DOCKERHUB_USERNAME::"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "DOCKERHUB_PASSWORD"
      value = "arn:aws:secretsmanager:us-east-1:493834426110:secret:cribr-dockerhub-credentials-0e7HCI:DOCKERHUB_PASSWORD::"
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "SONAR_PROJECT_KEY"
      value = "darlingtonogbuefi_app-containerization"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "ECR_REPO_URI"
      value = "493834426110.dkr.ecr.us-east-1.amazonaws.com/cribr-app-repo"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = "cribr-ns"
    }

    environment_variable {
      name  = "DEPLOYMENT_YAML"
      value = "cribr-cicd/deployment.yaml"
    }

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "cribr-cicd/buildspec.yml"  # make sure this matches your repo
  }

  # Optional: enable CloudWatch logs
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/${var.project_name}"
      stream_name = "build-log"
    }
  }
}
