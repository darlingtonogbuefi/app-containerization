// cribr-core-infra\cribr-core-stack\main.tf

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
}

#############################################
# AWS Provider
#############################################
provider "aws" {
  region = var.region
}

#############################################
# Availability Zones
#############################################
data "aws_availability_zones" "available" {}

#############################################
# VPC Module
#############################################
module "cribr_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Name"                                      = "${var.name_prefix}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

#############################################
# EKS Cluster Module
#############################################
module "cribr_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"
  vpc_id          = module.cribr_vpc.vpc_id
  subnet_ids      = module.cribr_vpc.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Managed Node Groups
  eks_managed_node_groups = {
    default = {
      node_group_name = "${var.name_prefix}-node-group"
      desired_size   = 4
      max_size       = 5
      min_size       = 3
      instance_types = ["t3.micro"]
      subnet_ids     = module.cribr_vpc.private_subnets
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      tags = {
        Name        = "${var.name_prefix}-node-group"
        Environment = "dev"
        Terraform   = "true"
      }
    }
  }

  tags = {
    Name        = "${var.name_prefix}-eks"
    Terraform   = "true"
    Environment = "dev"
  }
}

#############################################
# Data Sources for EKS
#############################################
data "aws_eks_cluster" "cribr" {
  name       = module.cribr_eks.cluster_name
  depends_on = [module.cribr_eks]
}

data "aws_eks_cluster_auth" "cribr" {
  name       = module.cribr_eks.cluster_name
  depends_on = [module.cribr_eks]
}

