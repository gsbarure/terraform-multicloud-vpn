locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── Public IP for the VPN Gateway ─────────────
resource "azurerm_public_ip" "vpn_gw" {
  name                = "${local.name_prefix}-vpngw-pip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Virtual Network Gateway (uses existing GatewaySubnet) ──
resource "azurerm_virtual_network_gateway" "this" {
  name                = "${local.name_prefix}-vpngw"
  location            = var.region
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  tags = {
    Environment = var.environment
  }
}

# ── Local Network Gateway (on-prem side) ──────
resource "azurerm_local_network_gateway" "on_prem" {
  name                = "${local.name_prefix}-lng"
  location            = var.region
  resource_group_name = var.resource_group_name
  gateway_address     = var.on_prem_gateway_ip
  address_space       = [var.on_prem_cidr]

  tags = {
    Environment = var.environment
  }
}

# ── VPN Connection ────────────────────────────
resource "azurerm_virtual_network_gateway_connection" "this" {
  name                       = "${local.name_prefix}-vpn-conn"
  location                   = var.region
  resource_group_name        = var.resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_prem.id
  shared_key                 = var.shared_key

  tags = {
    Environment = var.environment
  }
}
