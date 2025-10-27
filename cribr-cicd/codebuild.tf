##cribr-cicd\codebuild.tf

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
    compute_type    = "BUILD_GENERAL1_SMALL"
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

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"  # updated path if buildspec is not at repo root
  }
}
