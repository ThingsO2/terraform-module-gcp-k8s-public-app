provider "kubernetes-alpha" {
  config_path    = "~/.kube/config"
  config_context = var.config_context
}

resource "kubernetes_manifest" "managed_certificate" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "ManagedCertificate"
    metadata = {
      name      = var.app_name
      namespace = local.namespace
    }
    spec = {
      domains = [
        "${var.app_name}.monom.ai"
      ]
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.config_context
}

resource "kubernetes_ingress" "this" {
  provider = kubernetes
  count    = var.ingres == true ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = local.namespace
    labels = {
      app = var.app_name
    }
    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "networking.gke.io/v1beta1.FrontendConfig"    = "${var.app_name}-ingress-security-config"
      "kubernetes.io/ingress.global-static-ip-name" = var.app_name
      "networking.gke.io/managed-certificates"      = var.app_name
    }
  }

  spec {
    rule {
      host = "${var.app_name}.monom.ai"
      http {
        path {
          backend {
            service_name = var.service_name
            service_port = var.service_port
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "frontend_config" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"
    metadata = {
      name      = "${var.app_name}-ingress-security-config"
      namespace = local.namespace
    }
    spec = {
      redirectToHttps = {
        enabled = true
      }
      sslPolicy = "${var.app_name}-ssl-policy"
    }
  }
}

provider "google" {}

resource "google_compute_global_address" "this" {
  name         = var.app_name
  project      = var.project
  address_type = "EXTERNAL"
}

resource "google_compute_ssl_policy" "this" {
  name            = "${var.app_name}-ssl-policy"
  project         = var.project
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "this" {
  name = "monom.ai."
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.app_name}.monom.ai"
  type    = "A"
  ttl     = "300"
  records = [google_compute_global_address.this.address]
}
