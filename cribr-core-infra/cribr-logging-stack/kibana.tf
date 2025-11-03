# cribr-core-infra\cribr-logging-stack\kibana.tf

#############################################
# Kibana Deployment via Helm
#############################################

resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = var.kibana_version
  timeout    = 300  # Increase timeout in case Kibana takes longer to start
  wait       = true

  # Elasticsearch host
  set {
    name  = "elasticsearchHosts"
    value = "https://elasticsearch-master.${var.namespace}.svc:9200"
  }

  # Elasticsearch authentication
  set {
    name  = "elasticsearch.username"
    value = "elastic"
  }

  set {
    name  = "elasticsearch.password"
    value = local.elastic_password
  }

  # Disable strict TLS verification (for dev/test only)
  set {
    name  = "elasticsearch.ssl.verificationMode"
    value = "none"
  }

  # Service type
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # CPU & Memory requests and limits
  set {
    name  = "resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "2Gi"
  }

  depends_on = [helm_release.elasticsearch]
}
