terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key != "" ? var.aws_access_key : null
  secret_key = var.aws_secret_key != "" ? var.aws_secret_key : null
}

# ── Mode A: Create new VPC + VPN ──────────────
module "aws_vpn" {
  source = "../../modules/aws-vpn"
  count  = var.use_existing_vpc ? 0 : 1

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
}

# ── Mode B: Attach VPN to existing VPC ────────
module "aws_vpn_existing" {
  source = "../../modules/aws-vpn-existing-vpc"
  count  = var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  vpc_id             = var.aws_vpc_id
  route_table_ids    = var.aws_route_table_ids
}

# ── Auto-generate VPN customer config file ────
# Runs after VPN connection is created and saves
# the config to vpn-customer-config.txt
locals {
  vpn_connection_id = var.use_existing_vpc ? module.aws_vpn_existing[0].vpn_tunnel_status : module.aws_vpn[0].vpn_tunnel_status
}

resource "null_resource" "download_vpn_config" {
  triggers = {
    vpn_connection_id = local.vpn_connection_id
  }

  provisioner "local-exec" {
    command = "aws ec2 get-vpn-connection-device-sample-configuration --vpn-connection-id ${local.vpn_connection_id} --vpn-connection-device-type-id 9005b6c1 --region ${var.region} --output text > vpn-customer-config.txt"
  }

  depends_on = [
    module.aws_vpn,
    module.aws_vpn_existing
  ]
}
