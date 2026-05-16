# ─────────────────────────────────────────────
# Global variables shared across all providers
# ─────────────────────────────────────────────

variable "cloud_provider" {
  description = "Target cloud provider: aws | azure | gcp"
  type        = string
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "cloud_provider must be one of: aws, azure, gcp"
  }
}

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
  description = "Cloud region to deploy into"
  type        = string
}

# ─────────────────────────────────────────────
# VPN shared settings
# ─────────────────────────────────────────────

variable "vpn_cidr" {
  description = "CIDR block for the VPN / VPC network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "on_prem_gateway_ip" {
  description = "Public IP of the on-premises VPN gateway"
  type        = string
}

variable "on_prem_cidr" {
  description = "CIDR block of the on-premises network"
  type        = string
  default     = "192.168.0.0/24"
}

variable "shared_key" {
  description = "Pre-shared key for the VPN tunnel (keep secret)"
  type        = string
  sensitive   = true
}

# ─────────────────────────────────────────────
# AWS-specific variables
# ─────────────────────────────────────────────

variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  default     = ""
  sensitive   = true
}

# ─────────────────────────────────────────────
# Azure-specific variables
# ─────────────────────────────────────────────

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure service principal client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# ─────────────────────────────────────────────
# GCP-specific variables
# ─────────────────────────────────────────────

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_credentials_file" {
  description = "Path to GCP service account JSON key file"
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────
# "Bring your own VPC" mode
# Set use_existing_vpc = true to skip network
# creation and attach VPN to existing networks.
# ─────────────────────────────────────────────

variable "use_existing_vpc" {
  description = "Set to true to attach VPN to existing VPC/VNet/Network instead of creating one"
  type        = bool
  default     = false
}

# ── AWS existing VPC ──────────────────────────
variable "aws_vpc_id" {
  description = "Existing AWS VPC ID (required when use_existing_vpc = true and cloud_provider = aws)"
  type        = string
  default     = ""
}

variable "aws_route_table_ids" {
  description = "List of existing route table IDs to propagate VPN routes into"
  type        = list(string)
  default     = []
}

# ── Azure existing VNet ───────────────────────
variable "azure_resource_group_name" {
  description = "Existing Azure resource group name (required when use_existing_vpc = true and cloud_provider = azure)"
  type        = string
  default     = ""
}

variable "azure_gateway_subnet_id" {
  description = "ID of the existing GatewaySubnet in Azure (must be named 'GatewaySubnet')"
  type        = string
  default     = ""
}

# ── GCP existing VPC ──────────────────────────
variable "gcp_network_name" {
  description = "Existing GCP VPC network name (required when use_existing_vpc = true and cloud_provider = gcp)"
  type        = string
  default     = ""
}
