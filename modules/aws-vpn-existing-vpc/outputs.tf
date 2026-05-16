output "vpn_gateway_ip" {
  description = "Tunnel 1 outside IP (cloud side)"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "vpn_tunnel_2_ip" {
  description = "Tunnel 2 outside IP (redundant tunnel)"
  value       = aws_vpn_connection.this.tunnel2_address
}

output "vpn_tunnel_status" {
  description = "VPN connection ID"
  value       = aws_vpn_connection.this.id
}

output "vpn_gateway_id" {
  description = "Virtual Private Gateway ID"
  value       = aws_vpn_gateway.this.id
}
