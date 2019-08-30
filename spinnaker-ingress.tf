resource "kubernetes_ingress" "spinnaker_deck" {
  metadata {
    name      = "spinnaker-deck"
    namespace = "spinnaker"

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "kubernetes.io/tls-acme"                     = "true"
    }
  }

  spec {
    tls {
      hosts       = [var.domain]
      secret_name = "spinnaker-tls"
    }

    rule {
      host = var.domain
      http {
        path {
          path = "/"
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
    }
  }

  spec {
    tls {
      hosts       = [var.domain]
      secret_name = "spinnaker-tls"
    }

    rule {
      host = var.domain
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