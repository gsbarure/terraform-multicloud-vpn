# 🌐 Terraform Multi-Cloud VPN

> Deploy a Site-to-Site VPN on **AWS**, **Azure**, or **GCP** using a single Terraform codebase.  
> Supports both **creating a new VPC** and **attaching to an existing VPC**.

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        YOUR CODEBASE                                │
│                                                                     │
│   envs/aws/        envs/azure/        envs/gcp/                    │
│   ├── main.tf      ├── main.tf        ├── main.tf                  │
│   ├── variables.tf ├── variables.tf   ├── variables.tf             │
│   ├── outputs.tf   ├── outputs.tf     ├── outputs.tf               │
│   └── *.tfvars     └── *.tfvars       └── *.tfvars                 │
│         │                 │                  │                      │
│         └─────────────────┴──────────────────┘                     │
│                           │                                         │
│                    modules/ (shared)                                │
│                    ├── aws-vpn/                                     │
│                    ├── aws-vpn-existing-vpc/                        │
│                    ├── azure-vpn/                                   │
│                    ├── azure-vpn-existing-vnet/                     │
│                    ├── gcp-vpn/                                     │
│                    └── gcp-vpn-existing-vpc/                        │
└─────────────────────────────────────────────────────────────────────┘
         │                   │                    │
         ▼                   ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌─────────────────┐
│     AWS      │   │      AZURE       │   │      GCP        │
│              │   │                  │   │                 │
│  VPC         │   │  VNet            │   │  VPC Network    │
│  VPN Gateway │   │  VPN Gateway     │   │  VPN Gateway    │
│  Customer GW │   │  Local Net GW    │   │  VPN Tunnel     │
│  VPN Conn    │   │  VPN Connection  │   │  Routes         │
└──────┬───────┘   └────────┬─────────┘   └──────┬──────────┘
       │                    │                     │
       └────────────────────┴─────────────────────┘
                            │
                    IPSec Tunnel (IKEv2)
                            │
                    ┌───────▼────────┐
                    │  ON-PREMISES   │
                    │  VPN Device    │
                    │  (Firewall /   │
                    │   Router)      │
                    └────────────────┘
```

### Two Deployment Modes

```
MODE A — Create new VPC + VPN          MODE B — Existing VPC + VPN only
─────────────────────────────          ─────────────────────────────────
use_existing_vpc = false               use_existing_vpc = true

Creates:                               Creates:
  ✅ VPC / VNet / Network                ✅ VPN Gateway
  ✅ Subnets                             ✅ Customer Gateway
  ✅ Internet Gateway                    ✅ VPN Connection
  ✅ Route Tables                        ✅ Route Propagation
  ✅ VPN Gateway                         ✅ Customer Config File
  ✅ Customer Gateway
  ✅ VPN Connection
  ✅ Customer Config File
```

---

## 📋 Prerequisites

| Tool        | Version   | Download |
|-------------|-----------|----------|
| Terraform   | >= 1.5.0  | [developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform/downloads) |
| AWS CLI     | >= 2.x    | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Git         | >= 2.x    | [git-scm.com](https://git-scm.com/download/win) |

---

## 🚀 Quick Start — AWS (Step by Step)

### Step 1 — Clone the repository

```cmd
git clone https://github.com/gsbarure/terraform-multicloud-vpn.git
cd terraform-multicloud-vpn
```

### Step 2 — Configure AWS credentials

```cmd
aws configure
```

Enter when prompted:
```
AWS Access Key ID:     <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name:   us-east-1
Default output format: json
```

Verify it works:
```cmd
aws sts get-caller-identity
```

You should see your Account ID and IAM user ARN.

### Step 3 — Create your tfvars file

```cmd
cd envs\aws
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
# ── Choose mode ───────────────────────────────
use_existing_vpc = true        # true = use existing VPC
                               # false = create new VPC

# ── VPN settings ─────────────────────────────
on_prem_gateway_ip = "YOUR_ON_PREM_PUBLIC_IP"   # Public IP of your router/firewall
on_prem_cidr       = "192.168.0.0/24"           # Your on-prem network CIDR
shared_key         = "YourStrongKey123abc"       # Pre-shared key (alphanumeric only)

# ── If use_existing_vpc = true ────────────────
aws_vpc_id          = "vpc-xxxxxxxxxxxxxxxxx"
aws_route_table_ids = ["rtb-xxxxxxxxx", "rtb-yyyyyyyyy"]

# ── If use_existing_vpc = false ───────────────
# vpn_cidr = "10.0.0.0/16"
```

> ⚠️ **Pre-shared key rules:** Only letters, numbers, and underscores. No `@`, `!`, `#` or special characters.

### Step 4 — Initialize Terraform

```cmd
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

### Step 5 — Preview changes

```cmd
terraform plan
```

Review the resources that will be created. No changes are made yet.

### Step 6 — Deploy

```cmd
terraform apply -auto-approve
```

Wait ~8 minutes for the VPN connection to provision.

### Step 7 — Check outputs

After apply completes you will see:

```
aws_account_id           = "362079386246"
aws_iam_user_arn         = "arn:aws:iam::362079386246:user/Gajanan"
aws_region               = "us-east-1"
environment              = "dev"
network_id               = "vpc-0061848e929c452e5"
vpc_cidr                 = "192.168.0.0/16"
vpc_name                 = "vpc-use11-name-dev"
vpn_customer_config_file = "./vpn-customer-config.txt"
vpn_gateway_id           = "vgw-xxxxxxxxxxxxxxxxx"
vpn_gateway_ip           = "x.x.x.x"
vpn_tunnel_status        = "vpn-xxxxxxxxxxxxxxxxx"
```

### Step 8 — Send config to customer

The file `envs/aws/vpn-customer-config.txt` is auto-generated.  
Send this file to your on-premises network team — it contains all tunnel settings.

---

## 🔁 Switching Clouds

### Azure

```cmd
cd envs\azure
copy terraform.tfvars.example terraform.tfvars
# Fill in azure_subscription_id, azure_tenant_id, azure_client_id, azure_client_secret
terraform init
terraform plan
terraform apply -auto-approve
```

### GCP

```cmd
cd envs\gcp
copy terraform.tfvars.example terraform.tfvars
# Fill in gcp_project_id and gcp_credentials_file
terraform init
terraform plan
terraform apply -auto-approve
```

---

## 🗂️ Repository Structure

```
terraform-multicloud-vpn/
│
├── README.md                          ← You are here
├── DEPLOYMENT-GUIDE.md                ← Detailed step-by-step guide
├── .gitignore                         ← Blocks secrets from git
│
├── envs/                              ← One folder per cloud
│   ├── aws/
│   │   ├── main.tf                    ← AWS provider + module calls
│   │   ├── variables.tf               ← Input variables
│   │   ├── outputs.tf                 ← All outputs incl. config file path
│   │   ├── terraform.tfvars           ← Your values (gitignored)
│   │   └── terraform.tfvars.example   ← Template (safe to commit)
│   ├── azure/
│   │   └── ...
│   └── gcp/
│       └── ...
│
└── modules/                           ← Reusable modules (shared)
    ├── aws-vpn/                       ← Mode A: new VPC + VPN
    ├── aws-vpn-existing-vpc/          ← Mode B: existing VPC + VPN only
    ├── azure-vpn/
    ├── azure-vpn-existing-vnet/
    ├── gcp-vpn/
    └── gcp-vpn-existing-vpc/
```

---

## 🧹 Destroy / Cleanup

To remove all resources:

```cmd
cd envs\aws
terraform destroy -auto-approve
```

---

## ❓ Troubleshooting

| Error | Fix |
|-------|-----|
| `InvalidVpnConnection.InvalidState` | Wait 2 more minutes and retry |
| `InvalidParameterValue: pre-shared key` | Remove special chars from `shared_key` |
| `AuthFailure` | Run `aws configure` and re-enter credentials |
| `Error: No valid credential sources` | Run `aws sts get-caller-identity` to verify login |
| `VPN Gateway already attached` | VPC already has a VGW — check AWS Console |

---

## 🔐 Security Notes

- Never commit `terraform.tfvars` — it is blocked by `.gitignore`
- Rotate the `shared_key` regularly
- Use IAM roles instead of access keys in production
- Store secrets in AWS Secrets Manager for production workloads
