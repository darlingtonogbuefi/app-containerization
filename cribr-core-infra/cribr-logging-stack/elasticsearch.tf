# cribr-core-infra\cribr-logging-stack\elasticsearch.tf

#############################################
# Elasticsearch Deployment via Helm
#############################################

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = var.elasticsearch_version
  timeout    = 900
  wait       = true

  # Number of Elasticsearch nodes / replicas
  set {
    name  = "replicas"
    value = "1"
  }

  # Enable security & TLS
  set {
    name  = "security.enabled"
    value = "true"
  }

  set {
    name  = "security.http.ssl.enabled"
    value = "true"
  }

  set {
    name  = "security.transport.ssl.enabled"
    value = "true"
  }

  # Set static password from Secrets Manager
  set {
    name  = "secret.password"
    value = local.elastic_password
  }

  set {
    name  = "security.autoGeneratePassword"
    value = "false"
  }

  # Persistent storage per node
  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = var.storage_size
  }

  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = "gp2"
  }

  # CPU & Memory requests and limits
  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }

  set {
    name  = "resources.requests.memory"
    value = "2Gi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "resources.limits.memory"
    value = "4Gi"
  }

  # Elasticsearch JVM heap settings
  set {
    name  = "esJavaOpts"
    value = "-Xms1g -Xmx1g"
  }
}

