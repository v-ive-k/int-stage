#Resource group create
resource "azurerm_resource_group" "main_rg" {
  name     = "int-staging-rg"
  location = "South Central US"
  tags     = var.tags
}

# Assign Resource Group access control
resource "azurerm_role_assignment" "owner_ra" {
  scope                = azurerm_resource_group.main_rg.id
  role_definition_name = "Owner"
  principal_id         = var.rg_owner_group_id
}

resource "azurerm_role_assignment" "contributor_ra" {
  scope                = azurerm_resource_group.main_rg.id
  role_definition_name = "Contributor"
  principal_id         = var.rg_contributor_group_id
}

resource "azurerm_role_assignment" "reader_ra" {
  scope                = azurerm_resource_group.main_rg.id
  role_definition_name = "Reader"
  principal_id         = var.rg_reader_group_id
}