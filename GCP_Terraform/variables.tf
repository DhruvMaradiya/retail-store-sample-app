variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default = "decent-rig-471906-h1"
}

variable "gcp_region" {
  description = "GCP region (e.g. us-central1)"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Base GKE cluster name (random suffix will be added)"
  type        = string
  default     = "retail-store"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "kubernetes_version" {
  description = "GKE version (Autopilot)"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  type    = string
  default = "5.51.6"
}

variable "enable_monitoring" {
  description = "Enable kube-prometheus-stack (expensive)"
  type        = bool
  default     = false
}