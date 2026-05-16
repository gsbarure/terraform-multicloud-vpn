output "vpn_gateway_ip" {
  description = "Tunnel 1 outside IP (cloud side)"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "vpn_tunnel_status" {
  description = "VPN connection ID"
  value       = aws_vpn_connection.this.id
}

output "network_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}
