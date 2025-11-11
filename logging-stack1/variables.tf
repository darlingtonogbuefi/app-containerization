# cribr-core-infra\cribr-logging-stack\variables.tf

#############################################
# Input Variables
#############################################

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace for logging components"
  type        = string
  default     = "logging"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "elasticsearch_version" {
  description = "Version of Elasticsearch Helm chart"
  type        = string
  default     = "8.5.1"
}

variable "kibana_version" {
  description = "Version of Kibana Helm chart"
  type        = string
  default     = "8.5.1"
}

variable "fluentd_version" {
  description = "Version of Fluentd Helm chart"
  type        = string
  default     = "0.5.3"
}

variable "storage_size" {
  description = "Persistent volume size for Elasticsearch"
  type        = string
  default     = "20Gi"
}

variable "kibana_host" {
  description = "DNS hostname for Kibana Ingress"
  type        = string
  default     = "logs.cribr.co.uk"
}

variable "kibana_certificate_arn" {
  description = "ACM certificate ARN for Kibana HTTPS"
  type        = string
  default     = "arn:aws:acm:us-east-1:493834426110:certificate/20786673-f28a-4f83-b855-c2df770e4448"
}

variable "elastic_secret_name" {
  description = "AWS Secrets Manager secret name storing elastic password"
  type        = string
  default     = "cribr/elasticsearch"
}


variable "elastic_password" {
  description = "Elasticsearch password for Kibana"
  type        = string
  sensitive   = true
}
