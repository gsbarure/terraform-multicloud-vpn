# 📘 Deployment Guide — Terraform Multi-Cloud VPN
### For: Junior Engineers / Day-1 Onboarding
### Version: 1.0 | Cloud: AWS / Azure / GCP

---

## 📌 What This Does

This Terraform project creates a **Site-to-Site IPSec VPN** between your cloud (AWS/Azure/GCP) and an on-premises network.

After running `terraform apply` you get:
- A VPN Gateway in the cloud
- A VPN tunnel to your on-premises device
- A configuration file to hand to your network team
- Full output showing account, region, VPC, and tunnel details

---

## 🖥️ Part 1 — Install Required Tools

### 1.1 Install Terraform

1. Go to: https://developer.hashicorp.com/terraform/downloads
2. Download **Windows AMD64** zip
3. Extract `terraform.exe` to `C:\terraform\`
4. Add to PATH:
   - Search "Environment Variables" in Windows
   - Edit `Path` under System Variables
   - Add `C:\terraform`
5. Open a new terminal and verify:
   ```cmd
   terraform version
   ```
   Expected: `Terraform v1.x.x`

---

### 1.2 Install AWS CLI

1. Go to: https://aws.amazon.com/cli/
2. Download and run the Windows MSI installer
3. Verify:
   ```cmd
   aws --version
   ```
   Expected: `aws-cli/2.x.x`

---

### 1.3 Install Git

1. Go to: https://git-scm.com/download/win
2. Download and run the installer (keep all defaults)
3. Open a **new** terminal and verify:
   ```cmd
   git --version
   ```
   Expected: `git version 2.x.x`

---

## 🔑 Part 2 — Configure AWS Access

### 2.1 Get AWS credentials

Ask your AWS admin for:
- Access Key ID
- Secret Access Key
- Region (e.g. `us-east-1`)

### 2.2 Configure the CLI

```cmd
aws configure
```

Enter:
```
AWS Access Key ID:     AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name:   us-east-1
Default output format: json
```

### 2.3 Verify access

```cmd
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/YourName"
}
```

If you see this — you are logged in. ✅

---

## 📥 Part 3 — Get the Code

```cmd
git clone https://github.com/gsbarure/terraform-multicloud-vpn.git
cd terraform-multicloud-vpn
```

---

## ⚙️ Part 4 — Configure Your Deployment

### 4.1 Go to the AWS environment folder

```cmd
cd envs\aws
```

### 4.2 Create your tfvars file

```cmd
copy terraform.tfvars.example terraform.tfvars
```

### 4.3 Edit terraform.tfvars

Open `terraform.tfvars` in any text editor (Notepad, VS Code, etc.)

#### Option A — You have an existing VPC

```hcl
project_name     = "multicloud-vpn"
environment      = "dev"
region           = "us-east-1"

use_existing_vpc = true

on_prem_gateway_ip  = "203.0.113.10"      # ← Your on-prem device public IP
on_prem_cidr        = "192.168.1.0/24"    # ← Your on-prem network range
shared_key          = "MyVPNKey2026abc"   # ← Letters and numbers only

aws_vpc_id = "vpc-0061848e929c452e5"      # ← Your VPC ID from AWS Console
aws_route_table_ids = [
  "rtb-098e3842bb929af08",                # ← Your route table IDs
  "rtb-095ec6b15403f6c33"
]
```

#### Option B — Create a new VPC

```hcl
project_name     = "multicloud-vpn"
environment      = "dev"
region           = "us-east-1"

use_existing_vpc = false
vpn_cidr         = "10.0.0.0/16"         # ← New VPC CIDR

on_prem_gateway_ip  = "203.0.113.10"
on_prem_cidr        = "192.168.1.0/24"
shared_key          = "MyVPNKey2026abc"
```

> ⚠️ **Important:** `shared_key` must be alphanumeric only.  
> ❌ Bad: `MyKey@2026!`  
> ✅ Good: `MyKey2026abc`

### 4.4 How to find your VPC ID and Route Table IDs

**VPC ID:**
- AWS Console → VPC → Your VPCs → copy the VPC ID

**Route Table IDs:**
- AWS Console → VPC → Route Tables → filter by your VPC → copy IDs

Or use CLI:
```cmd
aws ec2 describe-vpcs --region us-east-1 --output table
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-XXXXXXXX" --region us-east-1 --output table
```

---

## 🚀 Part 5 — Deploy

### 5.1 Initialize

```cmd
terraform init
```

This downloads the AWS provider. Takes ~1 minute.

Expected:
```
Terraform has been successfully initialized!
```

### 5.2 Preview

```cmd
terraform plan
```

Read through the output. You should see resources like:
- `aws_vpn_gateway`
- `aws_customer_gateway`
- `aws_vpn_connection`

No changes are made at this step.

### 5.3 Deploy

```cmd
terraform apply -auto-approve
```

⏳ This takes **5-10 minutes**. The VPN connection takes time to provision in AWS.

You will see progress like:
```
module.aws_vpn_existing[0].aws_vpn_gateway.this: Creating...
module.aws_vpn_existing[0].aws_vpn_gateway.this: Still creating... [30s elapsed]
...
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

---

## 📊 Part 6 — Read the Outputs

After apply you will see:

```
Outputs:

aws_account_id           = "362079386246"
aws_iam_user_arn         = "arn:aws:iam::362079386246:user/Gajanan"
aws_region               = "us-east-1"
environment              = "dev"
network_id               = "vpc-0061848e929c452e5"
vpc_cidr                 = "192.168.0.0/16"
vpc_name                 = "vpc-use11-name-dev"
vpn_customer_config_file = "./vpn-customer-config.txt"
vpn_gateway_id           = "vgw-0fb0504664a952b44"
vpn_gateway_ip           = "18.209.178.38"
vpn_tunnel_status        = "vpn-00833fd894f7ade04"
```

| Output | What it means |
|--------|---------------|
| `aws_account_id` | Your AWS account number |
| `aws_iam_user_arn` | Who deployed this |
| `aws_region` | Where it was deployed |
| `vpc_name` | Which VPC was used |
| `vpc_cidr` | VPC IP range |
| `vpn_gateway_ip` | Cloud-side tunnel IP (give to on-prem team) |
| `vpn_tunnel_status` | VPN Connection ID in AWS |
| `vpn_customer_config_file` | Path to config file for on-prem team |

To see outputs again anytime:
```cmd
terraform output
```

---

## 📄 Part 7 — Customer Configuration File

The file `vpn-customer-config.txt` is auto-generated in `envs/aws/`.

It contains:
- Tunnel 1 and Tunnel 2 settings
- Pre-shared keys
- IKE / IPSec parameters
- Inside and outside IP addresses
- Static routing instructions

**Send this file to your on-premises network team** — they use it to configure their firewall/router.

---

## ✅ Part 8 — Verify in AWS Console

1. Go to: https://console.aws.amazon.com/vpc/home?region=us-east-1#VpnConnections
2. Find your VPN Connection ID (from output)
3. Status should show **Available**
4. Click on it → **Tunnel Details** tab → tunnels show **UP** once on-prem is configured

---

## 🧹 Part 9 — Cleanup (Destroy)

To remove all resources when done:

```cmd
terraform destroy -auto-approve
```

This deletes the VPN Gateway, Customer Gateway, VPN Connection, and routes.  
It does **NOT** delete your existing VPC (in existing-VPC mode).

---

## 🔁 Part 10 — Switching to Azure or GCP

### Azure

```cmd
cd ..\azure
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with:
```hcl
azure_subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_client_secret   = "your-client-secret"
region                = "East US"
on_prem_gateway_ip    = "203.0.113.10"
on_prem_cidr          = "192.168.1.0/24"
shared_key            = "MyVPNKey2026abc"
```

Then:
```cmd
terraform init
terraform apply -auto-approve
```

### GCP

```cmd
cd ..\gcp
copy terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with:
```hcl
gcp_project_id       = "my-gcp-project-id"
gcp_credentials_file = "C:/Users/YourName/.gcp/service-account.json"
region               = "us-central1"
on_prem_gateway_ip   = "203.0.113.10"
on_prem_cidr         = "192.168.1.0/24"
shared_key           = "MyVPNKey2026abc"
```

Then:
```cmd
terraform init
terraform apply -auto-approve
```

---

## ❓ Troubleshooting

### "aws: command not found"
→ AWS CLI not installed or not in PATH. Reinstall from https://aws.amazon.com/cli/

### "terraform: command not found"
→ Terraform not in PATH. Add `C:\terraform` to System Environment Variables.

### "Error: No valid credential sources found"
→ Run `aws configure` and enter your credentials.

### "InvalidParameterValue: pre-shared key contains invalid characters"
→ Remove special characters from `shared_key`. Use only letters and numbers.

### "VpnGatewayAttachmentLimitExceeded"
→ Your VPC already has a VPN Gateway attached. Check AWS Console → VPC → Virtual Private Gateways.

### "Still creating... [10m elapsed]"
→ Normal. AWS VPN connections take up to 10 minutes. Wait it out.

### Plan shows 0 resources
→ Check that `use_existing_vpc` is set correctly and `aws_vpc_id` is filled in.

---

## 📞 Support

Raise an issue on GitHub:  
https://github.com/gsbarure/terraform-multicloud-vpn/issues
