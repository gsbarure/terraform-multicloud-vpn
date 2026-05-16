locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── Static external IP for the VPN gateway ────
resource "google_compute_address" "vpn_gw" {
  name    = "${local.name_prefix}-vpn-ip"
  region  = var.region
  project = var.gcp_project_id
}

# ── Classic VPN Gateway on existing network ───
resource "google_compute_vpn_gateway" "this" {
  name    = "${local.name_prefix}-vpngw"
  network = var.network_name
  region  = var.region
  project = var.gcp_project_id
}

# ── Forwarding rules (ESP, UDP 500, UDP 4500) ─
resource "google_compute_forwarding_rule" "esp" {
  name        = "${local.name_prefix}-fr-esp"
  region      = var.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_gw.address
  target      = google_compute_vpn_gateway.this.id
  project     = var.gcp_project_id
}

resource "google_compute_forwarding_rule" "udp500" {
  name        = "${local.name_prefix}-fr-udp500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_gw.address
  target      = google_compute_vpn_gateway.this.id
  project     = var.gcp_project_id
}

resource "google_compute_forwarding_rule" "udp4500" {
  name        = "${local.name_prefix}-fr-udp4500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_gw.address
  target      = google_compute_vpn_gateway.this.id
  project     = var.gcp_project_id
}

# ── VPN Tunnel ────────────────────────────────
resource "google_compute_vpn_tunnel" "this" {
  name               = "${local.name_prefix}-tunnel"
  region             = var.region
  peer_ip            = var.on_prem_gateway_ip
  shared_secret      = var.shared_key
  target_vpn_gateway = google_compute_vpn_gateway.this.id
  project            = var.gcp_project_id

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
  ]
}

# ── Route: send on-prem traffic through tunnel ─
resource "google_compute_route" "on_prem" {
  name                = "${local.name_prefix}-route-onprem"
  network             = var.network_name
  dest_range          = var.on_prem_cidr
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.this.id
  project             = var.gcp_project_id
}

# ── Firewall: allow inbound traffic from on-prem ──
resource "google_compute_firewall" "allow_vpn" {
  name    = "${local.name_prefix}-allow-vpn"
  network = var.network_name
  project = var.gcp_project_id

  allow {
    protocol = "all"
  }

  source_ranges = [var.on_prem_cidr]
}
