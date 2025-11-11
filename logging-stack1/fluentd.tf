# cribr-core-infra\cribr-logging-stack\elasticsearch.tf

#############################################
# Fluentd Deployment via Helm
#############################################

resource "helm_release" "fluentd" {
  name       = "fluentd"
  namespace  = var.namespace
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  version    = var.fluentd_version
  timeout    = 120  
  wait       = true

  set {
  name  = "image.tag"
  value = "v1.19-debian-elasticsearch8-1"
}


  # CPU & Memory requests
  set {
    name  = "resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "resources.requests.memory"
    value = "512Mi"
  }

  # CPU & Memory limits
  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }

  depends_on = [helm_release.elasticsearch]
}