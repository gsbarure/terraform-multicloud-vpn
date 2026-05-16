locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ── Resource Group ────────────────────────────
resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-rg"
  location = var.region

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ── Virtual Network ───────────────────────────
resource "azurerm_virtual_network" "this" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vpn_cidr]

  tags = {
    Environment = var.environment
  }
}

# ── Gateway Subnet (must be named GatewaySubnet)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vpn_cidr, 8, 0)]
}

# ── Public IP for the VPN Gateway ─────────────
resource "azurerm_public_ip" "vpn_gw" {
  name                = "${local.name_prefix}-vpngw-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# ── Virtual Network Gateway ───────────────────
resource "azurerm_virtual_network_gateway" "this" {
  name                = "${local.name_prefix}-vpngw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  tags = {
    Environment = var.environment
  }
}

# ── Local Network Gateway (on-prem side) ──────
resource "azurerm_local_network_gateway" "on_prem" {
  name                = "${local.name_prefix}-lng"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = var.on_prem_gateway_ip
  address_space       = [var.on_prem_cidr]

  tags = {
    Environment = var.environment
  }
}

# ── VPN Connection ────────────────────────────
resource "azurerm_virtual_network_gateway_connection" "this" {
  name                       = "${local.name_prefix}-vpn-conn"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_prem.id
  shared_key                 = var.shared_key

  tags = {
    Environment = var.environment
  }
}
