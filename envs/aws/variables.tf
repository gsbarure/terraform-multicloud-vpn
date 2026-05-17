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
  default = "us-east-1"
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

variable "aws_access_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "aws_vpc_id" {
  type    = string
  default = ""
}

variable "aws_route_table_ids" {
  type    = list(string)
  default = []
}
