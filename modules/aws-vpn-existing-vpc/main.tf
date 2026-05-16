locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── Virtual Private Gateway — attach to existing VPC ──
resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "${local.name_prefix}-vgw"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Customer Gateway (on-prem device) ─────────
resource "aws_customer_gateway" "this" {
  bgp_asn    = 65000
  ip_address = var.on_prem_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name        = "${local.name_prefix}-cgw"
    Environment = var.environment
  }
}

# ── Site-to-Site VPN Connection ───────────────
resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_preshared_key = var.shared_key

  tags = {
    Name        = "${local.name_prefix}-vpn"
    Environment = var.environment
  }
}

# ── Static route to on-prem network ───────────
resource "aws_vpn_connection_route" "on_prem" {
  destination_cidr_block = var.on_prem_cidr
  vpn_connection_id      = aws_vpn_connection.this.id
}

# ── Enable route propagation on existing route tables ──
resource "aws_vpn_gateway_route_propagation" "this" {
  for_each = toset(var.route_table_ids)

  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.value
}
