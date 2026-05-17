terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# ── Mode A: Create new VNet + VPN ─────────────
module "azure_vpn" {
  source = "../../modules/azure-vpn"
  count  = var.use_existing_vnet ? 0 : 1

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
}

# ── Mode B: Attach VPN to existing VNet ───────
module "azure_vpn_existing" {
  source = "../../modules/azure-vpn-existing-vnet"
  count  = var.use_existing_vnet ? 1 : 0

  project_name        = var.project_name
  environment         = var.environment
  region              = var.region
  on_prem_gateway_ip  = var.on_prem_gateway_ip
  on_prem_cidr        = var.on_prem_cidr
  shared_key          = var.shared_key
  resource_group_name = var.azure_resource_group_name
  gateway_subnet_id   = var.azure_gateway_subnet_id
}
