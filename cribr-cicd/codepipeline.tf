# cribr-cicd\codepipeline.tf

#############################################
# S3 Bucket for CodePipeline Artifacts
#############################################

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.artifacts_bucket

  # Automatically delete all objects (including versions) when destroying the bucket
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-artifacts"
    Environment = "CI/CD"
  }
}

#############################################
# Bucket Versioning
#############################################
resource "aws_s3_bucket_versioning" "artifacts_bucket_versioning" {
  bucket = aws_s3_bucket.artifacts_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#############################################
# Bucket Server-Side Encryption
#############################################
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_bucket_sse" {
  bucket = aws_s3_bucket.artifacts_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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
  # Source Stage (GitHub using CodeStar connection v2)
  #############################################
  stage {
  name = "Source"

  action {
    name             = "Git_Source"
    category         = "Source"
    owner            = "AWS"
    provider         = "CodeStarSourceConnection" # Use CodeStar provider
    version          = "1"
    output_artifacts = ["source_output"]

    configuration = {
      ConnectionArn    = var.github_codestar_connection_arn
      FullRepositoryId = replace(var.source_repo_url, "https://github.com/", "")
      BranchName       = var.branch_name
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
