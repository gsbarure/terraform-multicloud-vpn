terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.region
  credentials = var.gcp_credentials_file != "" ? file(var.gcp_credentials_file) : null
}

# ── Mode A: Create new VPC + VPN ──────────────
module "gcp_vpn" {
  source = "../../modules/gcp-vpn"
  count  = var.use_existing_vpc ? 0 : 1

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  vpn_cidr           = var.vpn_cidr
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  gcp_project_id     = var.gcp_project_id
}

# ── Mode B: Attach VPN to existing VPC ────────
module "gcp_vpn_existing" {
  source = "../../modules/gcp-vpn-existing-vpc"
  count  = var.use_existing_vpc ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  on_prem_gateway_ip = var.on_prem_gateway_ip
  on_prem_cidr       = var.on_prem_cidr
  shared_key         = var.shared_key
  gcp_project_id     = var.gcp_project_id
  network_name       = var.gcp_network_name
}
