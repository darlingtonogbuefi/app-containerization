#  cribr-cicd\main.tf

#############################################
# Terraform Configuration
#############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }

  required_version = ">= 1.6.0"
}

#############################################
# Providers
#############################################
provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

#############################################
# S3 Artifact Bucket (Optional - Create if Missing)
#############################################
# Uncomment if you want Terraform to create the artifact bucket
#
# resource "aws_s3_bucket" "artifacts" {
#   bucket = "${var.project_name}-artifacts-${var.aws_account_id}"
#   acl    = "private"
# }
#
# output "artifacts_bucket_name" {
#   value = aws_s3_bucket.artifacts.bucket
# }
