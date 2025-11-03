# cribr-core-infra\cribr-logging-stack\main.tf

#############################################
# Terraform Configuration and Providers
#############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "aws" {
  region = var.region
}

# EKS Cluster Data
data "aws_eks_cluster" "cribr" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cribr" {
  name = var.cluster_name
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cribr.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cribr.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cribr.token
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cribr.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cribr.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cribr.token
  }
}

# Namespace
resource "kubernetes_namespace" "logging" {
  metadata {
    name = var.namespace
  }
}


#############################################
# EBS CSI Driver Add-on for EKS
#############################################
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = var.cluster_name
  addon_name        = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"


  tags = {
    Name = "cribr-ebs-csi-driver"
    ManagedBy = "Terraform"
  }
}

locals {
  elastic_password = try(
    jsondecode(data.aws_secretsmanager_secret_version.elastic_password.secret_string)["elastic"],
    "defaultPassword123!"
  )
}
