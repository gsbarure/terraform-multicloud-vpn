output "vpn_gateway_ip" {
  description = "External IP of the GCP VPN gateway"
  value       = google_compute_address.vpn_gw.address
}

output "vpn_tunnel_status" {
  description = "VPN tunnel self-link"
  value       = google_compute_vpn_tunnel.this.self_link
}

output "vpn_gateway_id" {
  description = "VPN Gateway self-link"
  value       = google_compute_vpn_gateway.this.self_link
}
