#  cribr-core-infra\cribr-logging-stack2\main.tf

#############################################
# Terraform Configuration
#############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~> 0.9"
    }
  }
}

#############################################
# AWS Provider
#############################################
provider "aws" {
  region = var.region
}

#############################################
# EKS Data Sources
#############################################
data "aws_eks_cluster" "cribr" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cribr" {
  name = var.cluster_name
}

#############################################
# Kubernetes Provider (points to EKS)
#############################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cribr.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cribr.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cribr.token
}

#############################################
# Helm Provider (uses Kubernetes provider)
#############################################
provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = data.aws_eks_cluster.cribr.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cribr.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cribr.token
  }
}

#############################################
# Elasticstack Provider (API Key Auth)
#############################################
provider "elasticstack" {
  elasticsearch {
    endpoints = [var.elasticsearch_endpoint]
    api_key   = var.elastic_api_key
  }
}

#############################################
# AWS Secrets Manager (Elastic API Key + Fleet Info)
#############################################
resource "aws_secretsmanager_secret" "elastic_api_secret" {
  name        = "elastic-api-config"
  description = "Elastic Cloud API key and connection details for EKS monitoring"
}

resource "aws_secretsmanager_secret_version" "elastic_api_secret_ver" {
  secret_id     = aws_secretsmanager_secret.elastic_api_secret.id
  secret_string = jsonencode({
    api_key          = var.elastic_api_key,
    cloud_id         = var.elastic_cloud_id,
    fleet_url        = var.elastic_fleet_url,
    enrollment_token = var.elastic_enrollment_token
  })
}

data "aws_secretsmanager_secret_version" "elastic_api_secret" {
  secret_id = aws_secretsmanager_secret.elastic_api_secret.id
}

locals {
  elastic_secret = jsondecode(data.aws_secretsmanager_secret_version.elastic_api_secret.secret_string)
}

#############################################
# Deploy Elastic Agent via Helm
#############################################
resource "helm_release" "elastic_agent" {
  provider         = helm.eks
  name             = "elastic-agent"
  repository       = "https://helm.elastic.co"
  chart            = "elastic-agent"
  namespace        = "elastic-system"
  create_namespace = true

  set {
    name  = "fleet.enabled"
    value = true
  }

  set {
    name  = "fleet.url"
    value = local.elastic_secret["fleet_url"]
  }

  set {
    name  = "fleet.enrollmentToken"
    value = local.elastic_secret["enrollment_token"]
  }

  # Corrected API key auth configuration
  set {
    name  = "outputs.default.type"
    value = "ESPlainAuthAPI"
  }

  set {
    name  = "outputs.default.api_key"
    value = local.elastic_secret["api_key"]
  }

  set {
    name  = "outputs.default.hosts[0]"
    value = var.elasticsearch_endpoint
  }

  set {
    name  = "imagePullPolicy"
    value = "IfNotPresent"
  }

  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
}

#############################################
# Elastic Index Template (ES 7+ compatible)
#############################################
resource "elasticstack_elasticsearch_index_template" "cribr_logs_template" {
  name           = "cribr-logs-template"
  index_patterns = ["cribr-logs-*"]

  template {
    settings = jsonencode({
      "index.number_of_shards"   = 1
      "index.number_of_replicas" = 1
    })

    mappings = jsonencode({
      properties = {
        "@timestamp" = { type = "date" }
        "message"    = { type = "text" }
      }
    })
  }

  priority = 100
}
