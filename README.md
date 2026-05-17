# Terraform Multi-Cloud VPN

Deploy a Site-to-Site IPSec VPN on **AWS**, **Azure**, or **GCP** using a single Terraform codebase.  
Attaches to an **existing VPC/VNet/Network** — no new network resources created.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        REPOSITORY STRUCTURE                         │
│                                                                     │
│   envs/aws/          envs/azure/          envs/gcp/                │
│   (AWS provider      (Azure provider      (GCP provider            │
│    only)              only)                only)                   │
│       │                   │                    │                   │
│       └───────────────────┴────────────────────┘                   │
│                           │                                         │
│                    modules/ (shared)                                │
│              aws-vpn-existing-vpc                                   │
│              azure-vpn-existing-vnet                                │
│              gcp-vpn-existing-vpc                                   │
└─────────────────────────────────────────────────────────────────────┘
         │                   │                    │
         ▼                   ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌─────────────────┐
│     AWS      │   │      AZURE       │   │      GCP        │
│  Existing    │   │  Existing VNet   │   │  Existing VPC   │
│  VPC         │   │                  │   │  Network        │
│              │   │                  │   │                 │
│  + VPN GW    │   │  + VPN Gateway   │   │  + VPN Gateway  │
│  + CGW       │   │  + Local Net GW  │   │  + VPN Tunnel   │
│  + VPN Conn  │   │  + VPN Conn      │   │  + Routes       │
│  + Routes    │   │                  │   │                 │
└──────┬───────┘   └────────┬─────────┘   └──────┬──────────┘
       │                    │                     │
       └────────────────────┴─────────────────────┘
                            │
                    IPSec Tunnel (IKEv2)
                            │
                   ┌────────▼────────┐
                   │  ON-PREMISES    │
                   │  VPN Device     │
                   └─────────────────┘
```

---

## Authentication

This setup supports **Okta SSO / federated roles** — no static credentials needed.

### Using Okta SSO (recommended)

```cmd
aws sso login --profile Cloud_DevOps
```

Then set in `terraform.tfvars`:
```hcl
aws_profile = "Cloud_DevOps"
```

Terraform picks up the session automatically. No keys stored anywhere.

### Using default credential chain

Leave `aws_profile` empty — Terraform uses `~/.aws/credentials` default profile.

### Using static credentials

Set `aws_access_key` and `aws_secret_key` in `terraform.tfvars` (not recommended for production).

---

## Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Terraform | >= 1.5.0 | [developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform/downloads) |
| AWS CLI | >= 2.x | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Git | >= 2.x | [git-scm.com](https://git-scm.com/download/win) |

---

## Quick Start — AWS

```cmd
git clone https://github.com/gsbarure/terraform-multicloud-vpn.git
cd terraform-multicloud-vpn\envs\aws

copy terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply -auto-approve
```

---

## Outputs

After apply:

```
aws_account_id           = "362079386246"
aws_iam_principal        = "arn:aws:iam::362079386246:assumed-role/Cloud_DevOps/Gajanan"
aws_region               = "us-east-1"
environment              = "dev"
vpc_id                   = "vpc-0061848e929c452e5"
vpc_name                 = "vpc-use11-name-dev"
vpc_cidr                 = "192.168.0.0/16"
vpn_gateway_id           = "vgw-xxxxxxxxxxxxxxxxx"
vpn_gateway_ip           = "x.x.x.x"
vpn_connection_id        = "vpn-xxxxxxxxxxxxxxxxx"
vpn_customer_config_file = "./vpn-customer-config.txt"
```

The file `vpn-customer-config.txt` is auto-generated — send it to your on-premises network team.

---

## Repository Structure

```
terraform-multicloud-vpn/
├── README.md
├── DEPLOYMENT-GUIDE.md
├── docs/
│   └── VPN-Deployment-Guide.html      ← Downloadable guide (open in browser → Print as PDF)
├── envs/
│   ├── aws/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.example
│   │   └── terraform.tfvars           ← Your values (gitignored)
│   ├── azure/
│   └── gcp/
└── modules/
    ├── aws-vpn-existing-vpc/
    ├── azure-vpn-existing-vnet/
    └── gcp-vpn-existing-vpc/
```

---

## Cleanup

```cmd
terraform destroy -auto-approve
```

Removes VPN Gateway, Customer Gateway, VPN Connection, and route propagation.  
Does not touch the existing VPC.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `InvalidParameterValue: pre-shared key` | Use alphanumeric characters only in `shared_key` |
| `AuthFailure` | Run `aws sso login --profile Cloud_DevOps` |
| `VpnGatewayAttachmentLimitExceeded` | VPC already has a VPN Gateway attached |
| `Still creating... [10m elapsed]` | Normal — AWS VPN connections take up to 10 minutes |
