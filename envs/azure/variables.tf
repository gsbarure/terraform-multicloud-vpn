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
  default = "East US"
}

variable "use_existing_vnet" {
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

variable "azure_subscription_id" {
  type      = string
  sensitive = true
}

variable "azure_tenant_id" {
  type      = string
  sensitive = true
}

variable "azure_client_id" {
  type      = string
  sensitive = true
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}

variable "azure_resource_group_name" {
  type    = string
  default = ""
}

variable "azure_gateway_subnet_id" {
  type    = string
  default = ""
}
