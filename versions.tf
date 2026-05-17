terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ─────────────────────────────────────────────
# Provider configs — unused providers are
# harmless when their modules have count = 0,
# BUT they still try to authenticate at plan.
# Set skip flags to avoid credential errors
# when only one cloud is being used.
# ─────────────────────────────────────────────
