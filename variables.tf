variable "project" {
  type = string
}

variable "app_name" {
  type = string
}

variable "config_context" {
  type = string
}

variable "ingres" {
  type    = bool
  default = false
}

variable "service_name" {
  type    = string
  default = ""
}

variable "service_port" {
  type    = string
  default = ""
}

variable "namespace" {
  type    = string
  default = null
}

locals {
  namespace = var.namespace != null ? var.namespace : var.app_name
}