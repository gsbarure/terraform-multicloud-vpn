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

# ─────────────────────────────────────────────
# Authentication — three options (pick one):
#
# Option 1: Okta / SSO federated role (recommended)
#   aws sso login --profile Cloud_DevOps
#   set AWS_PROFILE=Cloud_DevOps
#
# Option 2: Named profile in ~/.aws/config
#   profile = "Cloud_DevOps"
#
# Option 3: Static credentials in terraform.tfvars
#   aws_access_key / aws_secret_key
# ─────────────────────────────────────────────

provider "aws" {
  region  = var.region
  profile = var.aws_profile != "" ? var.aws_profile : null

  # Static creds — only used if aws_profile is empty
  access_key = var.aws_profile == "" && var.aws_access_key != "" ? var.aws_access_key : null
  secret_key = var.aws_profile == "" && var.aws_secret_key != "" ? var.aws_secret_key : null
}

# ── Attach VPN to existing VPC ────────────────
module "aws_vpn_existing" {
  source = "../../modules/aws-vpn-existing-vpc"

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
resource "null_resource" "download_vpn_config" {
  triggers = {
    vpn_connection_id = module.aws_vpn_existing.vpn_tunnel_status
  }

  provisioner "local-exec" {
    command = "aws ec2 get-vpn-connection-device-sample-configuration --vpn-connection-id ${module.aws_vpn_existing.vpn_tunnel_status} --vpn-connection-device-type-id 9005b6c1 --region ${var.region} --output text > vpn-customer-config.txt"
  }

  depends_on = [module.aws_vpn_existing]
}
