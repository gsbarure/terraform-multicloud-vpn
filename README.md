# terraform-multicloud-vpn

Single Terraform codebase that creates a **Site-to-Site VPN** on **AWS**, **Azure**, or **GCP** — just change one variable.

## Architecture

```
main.tf
  ├── module "aws_vpn"   (count = 1 when cloud_provider = "aws")
  ├── module "azure_vpn" (count = 1 when cloud_provider = "azure")
  └── module "gcp_vpn"   (count = 1 when cloud_provider = "gcp")
```

Each module creates:
| Resource | AWS | Azure | GCP |
|---|---|---|---|
| Network | VPC | VNet | VPC Network |
| Gateway | Virtual Private Gateway | VNet Gateway (VpnGw1) | Classic VPN Gateway |
| On-prem peer | Customer Gateway | Local Network Gateway | VPN Tunnel peer |
| Connection | Site-to-Site VPN Connection | VNet Gateway Connection | VPN Tunnel |
| Routing | Route Table + propagation | Automatic | Compute Route |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- Credentials for your target cloud (see below)
- Public IP of your on-premises VPN device

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/<your-org>/terraform-multicloud-vpn.git
cd terraform-multicloud-vpn

# 2. Create your tfvars from the example
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your real values

# 3. Init, plan, apply
terraform init
terraform plan
terraform apply
```

## Switching Cloud Providers

Edit `terraform.tfvars` and change `cloud_provider`:

```hcl
cloud_provider = "azure"   # was "aws"
region         = "East US" # Azure region format
```

Then run `terraform init -upgrade && terraform apply`.

## Credential Setup

### AWS
Set `aws_access_key` / `aws_secret_key` in `terraform.tfvars`, or use environment variables:
```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

### Azure
Set the four `azure_*` variables, or use:
```bash
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
```

### GCP
Set `gcp_project_id` and `gcp_credentials_file`, or use:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

## Outputs

| Output | Description |
|---|---|
| `vpn_gateway_ip` | Public IP of the cloud-side VPN gateway |
| `vpn_tunnel_status` | Connection/tunnel ID or self-link |
| `network_id` | VPC / VNet / Network ID |

## Security Notes

- **Never commit `terraform.tfvars`** — it contains secrets. The `.gitignore` blocks it.
- Use a secrets manager (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager) or CI/CD environment variables for production.
- Rotate the `shared_key` regularly.

## Repository Structure

```
.
├── main.tf                    # Provider config + module selection
├── variables.tf               # All input variables
├── outputs.tf                 # Unified outputs
├── versions.tf                # Provider version pins
├── terraform.tfvars.example   # Template — safe to commit
├── .gitignore
├── README.md
└── modules/
    ├── aws-vpn/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── azure-vpn/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── gcp-vpn/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
