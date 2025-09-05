terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
  }

  backend "azurerm" {}
}

# Ont-dev1 provider block
provider "azurerm" {
  features {}
  subscription_id = "ffe5c17f-a5cd-46d5-8137-b8c02ee481af"
}

# Ont-prod1 provider block
provider "azurerm" {
  features {}
  alias           = "prodcution"
  subscription_id = "58e2361d-344c-4e85-b45b-c7435e9e2a42"
}

# Ontellus cross tenant provider block
provider "azurerm" {
  features {}
  alias                = "OntellusTenant"
  subscription_id      = var.ONT-Dev1-SubID
  tenant_id            = var.Ontellus-Tenant
  client_id            = var.SP-Client-ID
  client_secret        = data.azurerm_key_vault_secret.Terraform-SP.value
  auxiliary_tenant_ids = [var.RecordsX-Technologies-Tenant]
}

# Ontellus cross tenant provider block
provider "azurerm" {
  features {}
  alias                = "RecordsXTenant"
  subscription_id      = var.IntSocial-Dev1-SubID
  tenant_id            = var.RecordsX-Technologies-Tenant
  client_id            = var.SP-Client-ID
  client_secret        = data.azurerm_key_vault_secret.Terraform-SP.value
  auxiliary_tenant_ids = [var.Ontellus-Tenant]
}

# Ontellus Ont-Prod1 cross tenant provider block
provider "azurerm" {
  features {}
  alias                = "OntellusProd1"
  subscription_id      = var.Ont-Prod1-SubID
  tenant_id            = var.Ontellus-Tenant
  client_id            = var.SP-Client-ID
  client_secret        = data.azurerm_key_vault_secret.Terraform-SP.value
  auxiliary_tenant_ids = [var.RecordsX-Technologies-Tenant]
}