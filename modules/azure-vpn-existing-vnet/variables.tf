variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "region"             { type = string }
variable "on_prem_gateway_ip" { type = string }
variable "on_prem_cidr"       { type = string }
variable "shared_key"         { type = string; sensitive = true }

# ── Existing VNet inputs ──────────────────────
variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "gateway_subnet_id" {
  description = "ID of the existing GatewaySubnet (must be named 'GatewaySubnet' in Azure)"
  type        = string
}
