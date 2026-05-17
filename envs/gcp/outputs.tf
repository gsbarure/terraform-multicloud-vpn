output "vpn_gateway_ip" {
  value = var.use_existing_vpc ? module.gcp_vpn_existing[0].vpn_gateway_ip : module.gcp_vpn[0].vpn_gateway_ip
}

output "vpn_tunnel_status" {
  value = var.use_existing_vpc ? module.gcp_vpn_existing[0].vpn_tunnel_status : module.gcp_vpn[0].vpn_tunnel_status
}
