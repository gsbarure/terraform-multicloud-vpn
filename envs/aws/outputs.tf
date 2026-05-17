# ── AWS account info ──────────────────────────
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.aws_vpc_id
}

# ── Outputs ───────────────────────────────────
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_iam_principal" {
  description = "IAM principal (user or role) used for deployment"
  value       = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "vpc_id" {
  description = "VPC ID used for this VPN"
  value       = var.aws_vpc_id
}

output "vpc_name" {
  description = "Name tag of the VPC"
  value       = lookup(data.aws_vpc.selected.tags, "Name", "N/A")
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = data.aws_vpc.selected.cidr_block
}

output "vpn_gateway_id" {
  description = "Virtual Private Gateway ID"
  value       = module.aws_vpn_existing.vpn_gateway_id
}

output "vpn_gateway_ip" {
  description = "Cloud-side VPN tunnel IP (share with on-prem team)"
  value       = module.aws_vpn_existing.vpn_gateway_ip
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = module.aws_vpn_existing.vpn_tunnel_status
}

output "vpn_customer_config_file" {
  description = "Path to the VPN customer configuration file"
  value       = "${path.module}/vpn-customer-config.txt"
}
