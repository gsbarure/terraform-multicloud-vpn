variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "multicloud-vpn"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ─────────────────────────────────────────────
# Authentication
# ─────────────────────────────────────────────

variable "aws_profile" {
  description = "AWS CLI named profile (e.g. Cloud_DevOps). Leave empty to use static credentials or default credential chain."
  type        = string
  default     = ""
}

variable "aws_access_key" {
  description = "AWS access key (only if not using a profile)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key (only if not using a profile)"
  type        = string
  default     = ""
  sensitive   = true
}

# ─────────────────────────────────────────────
# VPN settings
# ─────────────────────────────────────────────

variable "on_prem_gateway_ip" {
  description = "Public IP of the on-premises VPN device"
  type        = string
}

variable "on_prem_cidr" {
  description = "CIDR block of the on-premises network"
  type        = string
}

variable "shared_key" {
  description = "Pre-shared key for the VPN tunnel (alphanumeric only)"
  type        = string
  sensitive   = true
}

# ─────────────────────────────────────────────
# Existing VPC
# ─────────────────────────────────────────────

variable "aws_vpc_id" {
  description = "ID of the existing VPC to attach the VPN to"
  type        = string
}

variable "aws_route_table_ids" {
  description = "List of existing route table IDs to propagate VPN routes into"
  type        = list(string)
}
