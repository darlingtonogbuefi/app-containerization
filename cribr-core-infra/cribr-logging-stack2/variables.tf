# cribr-core-infra\cribr-logging-stack2\variables.tf

#############################################
# Terraform Variables
#############################################

variable "region" {
  description = "AWS region where EKS and Secrets Manager reside"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "cribr-cluster"
}

variable "elasticsearch_endpoint" {
  description = "Elastic Cloud Elasticsearch endpoint"
  type        = string
}

variable "elastic_api_key" {
  description = "Elastic Cloud API key"
  type        = string
  sensitive   = true
}

variable "elastic_cloud_id" {
  description = "Elastic Cloud deployment Cloud ID"
  type        = string
}

variable "elastic_fleet_url" {
  description = "Fleet Server URL for Elastic Agents"
  type        = string
}

variable "elastic_enrollment_token" {
  description = "Fleet enrollment token for Elastic Agents"
  type        = string
  sensitive   = true
}
