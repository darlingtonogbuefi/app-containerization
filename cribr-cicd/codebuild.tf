#  cribr-cicd\codebuild.tf

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
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }
}
