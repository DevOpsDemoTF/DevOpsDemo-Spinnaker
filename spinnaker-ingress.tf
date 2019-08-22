resource "kubernetes_ingress" "spinnaker_deck" {
  metadata {
    name      = "spinnaker-deck"
    namespace = "spinnaker"

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "kubernetes.io/tls-acme"                     = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/auth-url"       = "https://$host/oauth2/auth"
      "nginx.ingress.kubernetes.io/auth-signin"    = "https://$host/oauth2/start?rd=$request_uri"
    }
  }

  spec {
    tls {
      hosts       = [var.k8s_fqdn]
      secret_name = "spinnaker-tls"
    }

    rule {
      host = var.k8s_fqdn
      http {
        path {
          path = "/spinnaker(/|$)(.*)"
          backend {
            service_name = "spin-deck"
            service_port = "9000"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "spinnaker_gate" {
  metadata {
    name      = "spinnaker-gate"
    namespace = "spinnaker"

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "kubernetes.io/tls-acme"                     = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/auth-url"       = "https://$host/oauth2/auth"
      "nginx.ingress.kubernetes.io/auth-signin"    = "https://$host/oauth2/start?rd=$request_uri"
    }
  }

  spec {
    tls {
      hosts       = [var.k8s_fqdn]
      secret_name = "spinnaker-tls"
    }

    rule {
      host = var.k8s_fqdn
      http {
        path {
          path = "/gate(/|$)(.*)"
          backend {
            service_name = "spin-gate"
            service_port = "8084"
          }
        }
      }
    }
  }
}