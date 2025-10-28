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

  # Use the existing VPC and subnets from your cluster
  vpc_id     = "vpc-0d97a781019ed571d"
  subnet_ids = [
    "subnet-0b560efca52b2845e",
    "subnet-0c8dd61ab95ef8286"
  ]

  # Use the existing IAM role ARN
  iam_role_arn = "arn:aws:iam::493834426110:role/cribr-cluster-cluster-20251026112651202200000001"


  enable_irsa = true

  # Endpoint access matches the existing cluster
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Managed Node Groups (update subnet_ids to match existing cluster)
  eks_managed_node_groups = {
    default = {
      node_group_name = "${var.name_prefix}-node-group"
      desired_size   = 3
      max_size       = 5
      min_size       = 3
      instance_types = ["t3.micro"]
      subnet_ids     = [
        "subnet-0b560efca52b2845e",
        "subnet-0c8dd61ab95ef8286"
      ]
      ami_type  = "AL2023_x86_64_STANDARD"
      disk_size = 20

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

