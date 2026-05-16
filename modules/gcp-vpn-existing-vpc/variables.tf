variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "region"             { type = string }
variable "on_prem_gateway_ip" { type = string }
variable "on_prem_cidr"       { type = string }
variable "shared_key"         { type = string; sensitive = true }
variable "gcp_project_id"     { type = string }

# ── Existing VPC inputs ───────────────────────
variable "network_name" {
  description = "Name of the existing GCP VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the existing subnetwork (used for firewall scoping)"
  type        = string
  default     = ""
}
