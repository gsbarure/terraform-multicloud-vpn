output "vpn_gateway_ip" {
  description = "Public IP of the Azure VPN Gateway"
  value       = azurerm_public_ip.vpn_gw.ip_address
}

output "vpn_tunnel_status" {
  description = "VPN connection resource ID"
  value       = azurerm_virtual_network_gateway_connection.this.id
}

output "vpn_gateway_id" {
  description = "Virtual Network Gateway resource ID"
  value       = azurerm_virtual_network_gateway.this.id
}
