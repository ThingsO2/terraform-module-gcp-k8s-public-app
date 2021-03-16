terraform {
  required_providers {
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      version = "0.2.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 3.51.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
  }
}