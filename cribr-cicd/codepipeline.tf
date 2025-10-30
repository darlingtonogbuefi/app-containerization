# ///cribr-cicd\codepipeline.tf

#############################################
# S3 Bucket for CodePipeline Artifacts
#############################################

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.artifacts_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = "CI/CD"
  }
}

#############################################
# AWS CodePipeline
#############################################

resource "aws_codepipeline" "cribr_pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts_bucket.bucket
  }

  #############################################
  # Source Stage (GitHub)
  #############################################
  stage {
    name = "Source"

    action {
      name             = "Git_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = split("/", replace(var.source_repo_url, "https://github.com/", ""))[0]
        Repo       = split("/", replace(var.source_repo_url, "https://github.com/", ""))[1]
        Branch     = var.branch_name
        OAuthToken = var.github_oauth_token
      }
    }
  }

  #############################################
  # Build Stage (CodeBuild)
  #############################################
  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cribr_build.name
      }
    }
  }
}
