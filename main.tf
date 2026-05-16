# ─────────────────────────────────────────────
# Provider configuration — only the selected
# provider block is actually used at runtime.
# ─────────────────────────────────────────────

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.region
  credentials = var.gcp_credentials_file != "" ? file(var.gcp_credentials_file) : null
}

# ─────────────────────────────────────────────
# Module selection via count trick
# Only the matching module is created.
# ─────────────────────────────────────────────

# ─────────────────────────────────────────────
# Mode A: Create new VPC + VPN
# ─────────────────────────────────────────────

module "aws_vpn" {
  source = "./modules/aws-vpn"
  count  = var.cloud_provider == "aws" && !var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
}

module "azure_vpn" {
  source = "./modules/azure-vpn"
  count  = var.cloud_provider == "azure" && !var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
}

module "gcp_vpn" {
  source = "./modules/gcp-vpn"
  count  = var.cloud_provider == "gcp" && !var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  gcp_project_id     = var.gcp_project_id
}

# ─────────────────────────────────────────────
# Mode B: Attach VPN to existing VPC/VNet/Network
# ─────────────────────────────────────────────

module "aws_vpn_existing" {
  source = "./modules/aws-vpn-existing-vpc"
  count  = var.cloud_provider == "aws" && var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  vpc_id             = var.aws_vpc_id
  route_table_ids    = var.aws_route_table_ids
}

module "azure_vpn_existing" {
  source = "./modules/azure-vpn-existing-vnet"
  count  = var.cloud_provider == "azure" && var.use_existing_vpc ? 1 : 0

  project_name          = var.project_name
  environment           = var.environment
  region                = var.region
  on_prem_gateway_ip    = var.on_prem_gateway_ip
  on_prem_cidr          = var.on_prem_cidr
  shared_key            = var.shared_key
  resource_group_name   = var.azure_resource_group_name
  gateway_subnet_id     = var.azure_gateway_subnet_id
}

module "gcp_vpn_existing" {
  source = "./modules/gcp-vpn-existing-vpc"
  count  = var.cloud_provider == "gcp" && var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  gcp_project_id     = var.gcp_project_id
  network_name       = var.gcp_network_name
}
