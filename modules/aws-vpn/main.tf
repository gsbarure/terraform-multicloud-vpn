locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── VPC ──────────────────────────────────────
resource "aws_vpc" "this" {
  cidr_block           = var.vpn_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.name_prefix}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Public subnet (for the VPN gateway ENI) ──
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpn_cidr, 8, 0)
  availability_zone = "${var.region}a"

  tags = {
    Name        = "${local.name_prefix}-public-subnet"
    Environment = var.environment
  }
}

# ── Internet Gateway ──────────────────────────
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# ── Virtual Private Gateway ───────────────────
resource "aws_vpn_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${local.name_prefix}-vgw"
    Environment = var.environment
  }
}

# ── Customer Gateway (on-prem side) ───────────
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

  # Tunnel 1 pre-shared key
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

# ── Route table: send on-prem traffic via VGW ─
resource "aws_route_table" "vpn" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.on_prem_cidr
    gateway_id = aws_vpn_gateway.this.id
  }

  tags = {
    Name = "${local.name_prefix}-vpn-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.vpn.id
}

# ── VPN Gateway route propagation ─────────────
resource "aws_vpn_gateway_route_propagation" "this" {
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = aws_route_table.vpn.id
}
