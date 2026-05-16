variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "region"             { type = string }
variable "on_prem_gateway_ip" { type = string }
variable "on_prem_cidr"       { type = string }
variable "shared_key"         { type = string; sensitive = true }

# ── Existing VPC inputs ───────────────────────
variable "vpc_id" {
  description = "ID of the existing VPC to attach the VPN to"
  type        = string
}

variable "route_table_ids" {
  description = "List of existing route table IDs to propagate VPN routes into"
  type        = list(string)
}
