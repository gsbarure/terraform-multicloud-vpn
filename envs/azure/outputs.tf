output "vpn_gateway_ip" {
  value = var.use_existing_vnet ? module.azure_vpn_existing[0].vpn_gateway_ip : module.azure_vpn[0].vpn_gateway_ip
}

output "vpn_tunnel_status" {
  value = var.use_existing_vnet ? module.azure_vpn_existing[0].vpn_tunnel_status : module.azure_vpn[0].vpn_tunnel_status
}
