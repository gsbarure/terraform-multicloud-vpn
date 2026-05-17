# Deployment Guide — Terraform Multi-Cloud VPN
**Version:** 1.0 | **Supported Clouds:** AWS / Azure / GCP

---

## Overview

This Terraform project creates a **Site-to-Site IPSec VPN** between an existing cloud VPC and an on-premises network.

**What gets created:**
- Virtual Private Gateway (attached to your existing VPC)
- Customer Gateway (representing your on-premises device)
- Site-to-Site VPN Connection (2 redundant tunnels)
- Static route to on-premises CIDR
- Route propagation on specified route tables
- Customer configuration file (`vpn-customer-config.txt`)

---

## Part 1 — Install Required Tools

### Terraform

1. Download from: https://developer.hashicorp.com/terraform/downloads
2. Select **Windows AMD64**
3. Extract `terraform.exe` to `C:\terraform\`
4. Add `C:\terraform` to System PATH:
   - Windows Search → "Edit the system environment variables"
   - Environment Variables → System Variables → Path → Edit → New → `C:\terraform`
5. Open a new terminal and verify:
   ```cmd
   terraform version
   ```

### AWS CLI

1. Download from: https://aws.amazon.com/cli/
2. Run the Windows MSI installer
3. Verify:
   ```cmd
   aws --version
   ```

### Git

1. Download from: https://git-scm.com/download/win
2. Run installer with default settings
3. Open a new terminal and verify:
   ```cmd
   git --version
   ```

---

## Part 2 — Authentication

### Option A — Okta SSO / Federated Role (Recommended)

If your organization uses Okta with AWS SSO, configure your profile once:

```cmd
aws configure sso
```

Enter when prompted:
```
SSO session name: okta
SSO start URL:    https://your-org.awsapps.com/start
SSO region:       us-east-1
SSO registration scopes: sso:account:access
```

Follow the browser prompt to authenticate via Okta.

Then log in before each session:
```cmd
aws sso login --profile Cloud_DevOps
```

Verify:
```cmd
aws sts get-caller-identity --profile Cloud_DevOps
```

Set in `terraform.tfvars`:
```hcl
aws_profile = "Cloud_DevOps"
```

Terraform will use the SSO session — no keys stored anywhere.

---

### Option B — Default Credential Chain

If credentials are already configured via `aws configure`:

```cmd
aws sts get-caller-identity
```

Leave `aws_profile` empty in `terraform.tfvars`:
```hcl
aws_profile = ""
```

---

### Option C — Static Credentials (not recommended for production)

```cmd
aws configure
```

Enter Access Key ID, Secret Access Key, region, output format.

Leave `aws_profile` empty and set in `terraform.tfvars`:
```hcl
aws_profile    = ""
aws_access_key = "AKIAIOSFODNN7EXAMPLE"
aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

---

## Part 3 — Get the Code

```cmd
git clone https://github.com/gsbarure/terraform-multicloud-vpn.git
cd terraform-multicloud-vpn
```

---

## Part 4 — Configure

### Go to the AWS environment folder

```cmd
cd envs\aws
```

### Create your tfvars file

```cmd
copy terraform.tfvars.example terraform.tfvars
```

### Edit terraform.tfvars

```hcl
project_name = "multicloud-vpn"
environment  = "dev"
region       = "us-east-1"

# Authentication
aws_profile = "Cloud_DevOps"   # or "" for default chain

# VPN settings
on_prem_gateway_ip = "203.0.113.10"    # Public IP of your on-prem device
on_prem_cidr       = "192.168.1.0/24"  # Your on-prem network CIDR
shared_key         = "MyVPNKey2026abc" # Alphanumeric only — no special characters

# Existing VPC
aws_vpc_id = "vpc-0061848e929c452e5"
aws_route_table_ids = [
  "rtb-098e3842bb929af08",
  "rtb-095ec6b15403f6c33"
]
```

> **shared_key rules:** Alphanumeric characters only. No `@`, `!`, `#`, `-` or spaces.

### How to find VPC ID and Route Table IDs

**From AWS Console:**
- VPC ID: AWS Console → VPC → Your VPCs
- Route Tables: AWS Console → VPC → Route Tables → filter by VPC

**From CLI:**
```cmd
aws ec2 describe-vpcs --region us-east-1 --output table
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-XXXXXXXX" --region us-east-1 --output table
```

---

## Part 5 — Deploy

### Initialize

```cmd
terraform init
```

Downloads the AWS provider. Expected output:
```
Terraform has been successfully initialized!
```

### Preview

```cmd
terraform plan
```

Review resources to be created. No changes made at this step.

### Apply

```cmd
terraform apply -auto-approve
```

Takes **5–10 minutes**. The VPN connection provisioning in AWS takes time.

---

## Part 6 — Outputs

After apply completes:

```
aws_account_id           = "362079386246"
aws_iam_principal        = "arn:aws:iam::362079386246:assumed-role/Cloud_DevOps/Gajanan"
aws_region               = "us-east-1"
environment              = "dev"
vpc_id                   = "vpc-0061848e929c452e5"
vpc_name                 = "vpc-use11-name-dev"
vpc_cidr                 = "192.168.0.0/16"
vpn_gateway_id           = "vgw-0fb0504664a952b44"
vpn_gateway_ip           = "18.209.178.38"
vpn_connection_id        = "vpn-00833fd894f7ade04"
vpn_customer_config_file = "./vpn-customer-config.txt"
```

To view outputs again at any time:
```cmd
terraform output
```

---

## Part 7 — Customer Configuration File

`envs/aws/vpn-customer-config.txt` is auto-generated after every apply.

Contents:
- Tunnel 1 and Tunnel 2 outside IP addresses
- Pre-shared keys
- IKE phase 1 and phase 2 parameters
- Inside IP addresses for tunnel interfaces
- Static routing instructions

Send this file to your on-premises network team to configure their device.

---

## Part 8 — Verify in AWS Console

1. Navigate to: **VPC → Site-to-Site VPN Connections**
2. Locate the VPN Connection ID from the output
3. Status: **Available**
4. Tunnel Details tab: tunnels show **UP** once on-prem device is configured

---

## Part 9 — Cleanup

```cmd
terraform destroy -auto-approve
```

Removes: VPN Gateway, Customer Gateway, VPN Connection, static route, route propagation.  
Does **not** modify the existing VPC or its subnets.

---

## Part 10 — Azure and GCP

### Azure

```cmd
cd ..\azure
copy terraform.tfvars.example terraform.tfvars
```

Fill in:
```hcl
azure_subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_tenant_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_secret       = "your-client-secret"
region                    = "East US"
on_prem_gateway_ip        = "203.0.113.10"
on_prem_cidr              = "192.168.1.0/24"
shared_key                = "MyVPNKey2026abc"
azure_resource_group_name = "my-existing-rg"
azure_gateway_subnet_id   = "/subscriptions/.../subnets/GatewaySubnet"
```

```cmd
terraform init
terraform apply -auto-approve
```

### GCP

```cmd
cd ..\gcp
copy terraform.tfvars.example terraform.tfvars
```

Fill in:
```hcl
gcp_project_id       = "my-gcp-project-id"
gcp_credentials_file = "C:/Users/YourName/.gcp/service-account.json"
region               = "us-central1"
on_prem_gateway_ip   = "203.0.113.10"
on_prem_cidr         = "192.168.1.0/24"
shared_key           = "MyVPNKey2026abc"
gcp_network_name     = "my-existing-vpc"
```

```cmd
terraform init
terraform apply -auto-approve
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `aws: command not found` | Reinstall AWS CLI and open a new terminal |
| `terraform: command not found` | Add `C:\terraform` to System PATH |
| `No valid credential sources` | Run `aws sso login --profile Cloud_DevOps` |
| `pre-shared key contains invalid characters` | Use alphanumeric characters only |
| `VpnGatewayAttachmentLimitExceeded` | VPC already has a VPN Gateway — check AWS Console |
| `Still creating... [10m elapsed]` | Normal — wait for AWS to finish provisioning |
| `Error: Profile not found` | Run `aws configure sso` to set up the SSO profile first |
