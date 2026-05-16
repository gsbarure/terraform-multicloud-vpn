# ─────────────────────────────────────────────
# Outputs resolve from whichever module is active
# (new VPC mode or existing VPC mode)
# ─────────────────────────────────────────────

locals {
  # Pick the active module output based on mode + provider
  vpn_gateway_ip = (
    var.cloud_provider == "aws" && !var.use_existing_vpc   ? module.aws_vpn[0].vpn_gateway_ip :
    var.cloud_provider == "aws" && var.use_existing_vpc    ? module.aws_vpn_existing[0].vpn_gateway_ip :
    var.cloud_provider == "azure" && !var.use_existing_vpc ? module.azure_vpn[0].vpn_gateway_ip :
    var.cloud_provider == "azure" && var.use_existing_vpc  ? module.azure_vpn_existing[0].vpn_gateway_ip :
    var.cloud_provider == "gcp" && !var.use_existing_vpc   ? module.gcp_vpn[0].vpn_gateway_ip :
    var.cloud_provider == "gcp" && var.use_existing_vpc    ? module.gcp_vpn_existing[0].vpn_gateway_ip :
    null
  )

  vpn_tunnel_status = (
    var.cloud_provider == "aws" && !var.use_existing_vpc   ? module.aws_vpn[0].vpn_tunnel_status :
    var.cloud_provider == "aws" && var.use_existing_vpc    ? module.aws_vpn_existing[0].vpn_tunnel_status :
    var.cloud_provider == "azure" && !var.use_existing_vpc ? module.azure_vpn[0].vpn_tunnel_status :
    var.cloud_provider == "azure" && var.use_existing_vpc  ? module.azure_vpn_existing[0].vpn_tunnel_status :
    var.cloud_provider == "gcp" && !var.use_existing_vpc   ? module.gcp_vpn[0].vpn_tunnel_status :
    var.cloud_provider == "gcp" && var.use_existing_vpc    ? module.gcp_vpn_existing[0].vpn_tunnel_status :
    null
  )
}

output "vpn_gateway_ip" {
  description = "Public IP of the cloud-side VPN gateway"
  value       = local.vpn_gateway_ip
}

output "vpn_tunnel_status" {
  description = "VPN connection/tunnel ID or self-link"
  value       = local.vpn_tunnel_status
}

output "network_id" {
  description = "VPC/VNet/Network ID (only populated in new-VPC mode)"
  value = (
    var.cloud_provider == "aws" && !var.use_existing_vpc   ? module.aws_vpn[0].network_id :
    var.cloud_provider == "azure" && !var.use_existing_vpc ? module.azure_vpn[0].network_id :
    var.cloud_provider == "gcp" && !var.use_existing_vpc   ? module.gcp_vpn[0].network_id :
    "N/A — using existing network"
  )
}
