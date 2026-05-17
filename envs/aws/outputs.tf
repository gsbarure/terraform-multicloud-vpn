# ── AWS account info data sources ─────────────
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ── VPC name lookup ───────────────────────────
data "aws_vpc" "selected" {
  id = var.use_existing_vpc ? var.aws_vpc_id : (length(module.aws_vpn) > 0 ? module.aws_vpn[0].network_id : "")
}

# ── Outputs ───────────────────────────────────
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_iam_user_arn" {
  description = "ARN of the IAM user running Terraform"
  value       = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region resources are deployed in"
  value       = data.aws_region.current.name
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "network_id" {
  description = "VPC ID used for this VPN"
  value       = var.use_existing_vpc ? var.aws_vpc_id : module.aws_vpn[0].network_id
}

output "vpc_name" {
  description = "Name tag of the VPC used"
  value       = data.aws_vpc.selected.tags["Name"]
}

output "vpc_cidr" {
  description = "CIDR block of the VPC used"
  value       = data.aws_vpc.selected.cidr_block
}

output "vpn_gateway_ip" {
  description = "Cloud-side VPN tunnel IP"
  value       = var.use_existing_vpc ? module.aws_vpn_existing[0].vpn_gateway_ip : module.aws_vpn[0].vpn_gateway_ip
}

output "vpn_tunnel_status" {
  description = "VPN connection ID"
  value       = var.use_existing_vpc ? module.aws_vpn_existing[0].vpn_tunnel_status : module.aws_vpn[0].vpn_tunnel_status
}

output "vpn_gateway_id" {
  description = "Virtual Private Gateway ID"
  value       = var.use_existing_vpc ? module.aws_vpn_existing[0].vpn_gateway_id : null
}

output "vpn_customer_config_file" {
  description = "Path to the VPN customer configuration file (send this to your on-prem team)"
  value       = "${path.module}/vpn-customer-config.txt"
}
