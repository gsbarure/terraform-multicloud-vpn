variable "project_name" {
  type    = string
  default = "multicloud-vpn"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "use_existing_vpc" {
  type    = bool
  default = false
}

variable "vpn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "on_prem_gateway_ip" {
  type = string
}

variable "on_prem_cidr" {
  type = string
}

variable "shared_key" {
  type      = string
  sensitive = true
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_credentials_file" {
  type    = string
  default = ""
}

variable "gcp_network_name" {
  type    = string
  default = ""
}
