variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "region"             { type = string }
variable "vpn_cidr"           { type = string }
variable "on_prem_gateway_ip" { type = string }
variable "on_prem_cidr"       { type = string }
variable "shared_key" {
  type      = string
  sensitive = true
}
variable "gcp_project_id"     { type = string }
