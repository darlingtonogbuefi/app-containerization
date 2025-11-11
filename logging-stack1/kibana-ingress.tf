resource "kubernetes_ingress_v1" "kibana" {
  metadata {
    name      = "kibana-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([
                                                   { "HTTP"  = 80 },
                                                   { "HTTPS" = 443 }
                                                 ])
      "alb.ingress.kubernetes.io/certificate-arn" = var.kibana_certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"    
    }

  }

  spec {
    rule {
      host = var.kibana_host

      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kibana-kibana" # service created by the Helm chart
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
  }
}
