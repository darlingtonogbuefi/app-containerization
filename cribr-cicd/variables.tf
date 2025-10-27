//  cribr-cicd\variables.tf


#############################################
# Input Variables for CI/CD
#############################################

variable "project_name" {
  description = "Name of the project (used in resource naming)"
  type        = string
  default     = "cribr"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "source_repo_url" {
  description = "GitHub repository URL (e.g., https://github.com/org/repo)"
  type        = string
}

variable "branch_name" {
  description = "Branch to build from"
  type        = string
  default     = "main"
}

variable "docker_image" {
  description = "Docker image used for the CodeBuild environment"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "compute_type" {
  description = "Compute type for CodeBuild (e.g., BUILD_GENERAL1_SMALL)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "artifacts_bucket" {
  description = "S3 bucket used by CodePipeline to store build artifacts"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub OAuth (Personal Access) Token for source authentication"
  type        = string
  sensitive   = true
}

variable "sonar_token" {
  description = "SonarQube authentication token used for static code analysis"
  type        = string
  sensitive   = true
}

variable "sonar_project_key" {
  description = "SonarQube project key used in analysis"
  type        = string
  default     = "cribr-ci-cd"
}