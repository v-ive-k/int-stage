# Get the main ont-dev1 route table
data "azurerm_route_table" "dev-scus-rt" {
  name                = "dev-scus-rt"
  resource_group_name = "NetworkServices-dev-scus-rg"
}

# Get the ont-prod1 IT virtual network
data "azurerm_virtual_network" "IT-Prod-SCUS-VNet" {
  provider            = azurerm.prodcution
  name                = "IT-Prod-SCUS-VNet"
  resource_group_name = "IT-Prod-RG"
}

# Get the ont-prod1 MR8-Prod-RG Virtual Networt
data "azurerm_virtual_network" "MR8-Prod-SCUS-VNet" {
  provider            = azurerm.prodcution
  name                = "MR8-Prod-SCUS-VNet"
  resource_group_name = "MR8-PROD-rg"
}

# Get the ont-dev1 Netowrking virtual network
data "azurerm_virtual_network" "network-dev-scus-vnet" {
  name                = "network-dev-scus-vnet"
  resource_group_name = "networkservices-dev-scus-rg"
}

# Get the Ont-Prod1 int-prod-rg virtual network
data "azurerm_virtual_network" "intertel-prod-scus-vnet" {
  provider            = azurerm.prodcution
  name                = "intertel-prod-scus-vnet"
  resource_group_name = "int-prod-rg"
}

# Get the Ont-Dev1 int-dev-rg virtual network
data "azurerm_virtual_network" "intertel-dev-scus-vnet" {
  #provider = 
  name                = "intertel-dev-scus-vnet"
  resource_group_name = "int-dev-rg"
}

# Get the IT Key Vault for passwords
data "azurerm_key_vault" "ONT-IT-KeyVault" {
  provider            = azurerm.prodcution
  name                = "ONT-IT-KeyVault"
  resource_group_name = "IT-Prod-RG"
}

# Get the passowrd to join AVD hosts and VMs to domain
data "azurerm_key_vault_secret" "intertel-svc-directoryservice" {
  provider     = azurerm.prodcution
  name         = "intertel-svc-directoryservice"
  key_vault_id = data.azurerm_key_vault.ONT-IT-KeyVault.id
}

#Get the ontadmin password to use for vm deployment
data "azurerm_key_vault_secret" "ontadmin" {
  provider     = azurerm.prodcution
  name         = "ontadmin"
  key_vault_id = data.azurerm_key_vault.ONT-IT-KeyVault.id
}

#Get the AVD Images
data "azurerm_shared_image" "AVD-INT-Win10-img" {
  provider            = azurerm.prodcution
  name                = "AVD-INT-Win10-img"
  gallery_name        = "Ont_Prod1_scus_scg"
  resource_group_name = "IT-Prod-RG"
}
data "azurerm_shared_image" "AVD-INT-Mgmt-Win10-img" {
  provider            = azurerm.prodcution
  name                = "AVD-INT-Mgmt-Win10-img"
  gallery_name        = "Ont_Prod1_scus_scg"
  resource_group_name = "IT-Prod-RG"
}

#Get the Terraform SP to RecordsX Technologies tenant value
data "azurerm_key_vault_secret" "Terraform-SP" {
  provider     = azurerm.prodcution
  name         = "3f31972c-b59f-480d-b4f3-71d39043b74e"
  key_vault_id = data.azurerm_key_vault.ONT-IT-KeyVault.id
}

# Get the social-prod-rg virtual network
# data "azurerm_virtual_network" "social-staging-scus-vnet" {
#   provider            = azurerm.RecordsXTenant
#   name                = "social-staging-scus-vnet"
#   resource_group_name = "social-staging-rg"
# }

# Get the Prod Mgmt subnet to use in networking rules
data "azurerm_subnet" "subnet-prod-mgmt" {
  provider             = azurerm.prodcution
  # name                 = "intertel-prod-mgmt-scus-snet"
  virtual_network_name = "intertel-prod-scus-vnet"
  resource_group_name  = "int-prod-rg"
}