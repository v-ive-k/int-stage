# Storage account for domain file shares
resource "azurerm_storage_account" "file_storage_acc" {
  name                = "stgintfiles01"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  large_file_share_enabled = "true"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["172.119.179.173", "47.180.141.242", "52.248.96.7", "35.134.145.242", "65.87.34.242"]
    virtual_network_subnet_ids = [azurerm_subnet.avd_snet.id, azurerm_subnet.internal_snet.id, data.azurerm_subnet.subnet-prod-mgmt.id]
  }
  azure_files_authentication {
    directory_type = "AD"
    # After this there is configuration that can be done in terraform but now set using AZ AD join account PS
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "File_SMB_Contributor_file_ra" {
  scope                = azurerm_storage_account.file_storage_acc.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.file_shares_contributor_group_id
}

resource "azurerm_storage_share" "file_share" {
  storage_account_name = azurerm_storage_account.file_storage_acc.name
  access_tier          = "TransactionOptimized"
  for_each             = var.file_shares

  name  = each.key
  quota = each.value.quota
}

resource "azurerm_private_endpoint" "file_endpoint" {
  name                          = "stgintfiles01-pep01"
  resource_group_name           = azurerm_resource_group.main_rg.name
  location                      = azurerm_resource_group.main_rg.location
  subnet_id                     = azurerm_subnet.internal_snet.id
  custom_network_interface_name = "stgintfiles01-nic"

  ip_configuration {
    name               = "stgintfiles01-ip-private"
    private_ip_address = cidrhost(var.internal_snet_address_prefix, 20)
    subresource_name   = "file"
  }

  private_service_connection {
    name                           = "stgintfiles01_psc"
    private_connection_resource_id = azurerm_storage_account.file_storage_acc.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

resource "azurerm_private_dns_a_record" "dns_file_share" {
  name                = "stgintfiles01"
  zone_name           = azurerm_private_dns_zone.privatelink-file-dns.name
  resource_group_name = azurerm_resource_group.main_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.file_endpoint.private_service_connection.0.private_ip_address]
}

# Storage account for AVD profiles
resource "azurerm_storage_account" "file_storage_profiles" {
  name                     = "stgintprofiles01"
  resource_group_name      = azurerm_resource_group.main_rg.name
  location                 = azurerm_resource_group.main_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  large_file_share_enabled = "true"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["172.119.179.173", "47.180.141.242", "52.248.96.7", "35.134.145.242", "65.87.34.242"]
    virtual_network_subnet_ids = [azurerm_subnet.avd_snet.id, azurerm_subnet.internal_snet.id]
  }

  azure_files_authentication {
    directory_type = "AD"
    # After this there is configuration that can be done in terraform but now set using AZ AD join account PS
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "File_SMB_Contributor_Profile_ra" {
  scope                = azurerm_storage_account.file_storage_profiles.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.file_profiles_contributor_group_id
}

resource "azurerm_storage_share" "file_storage_profiles" {
  storage_account_name = azurerm_storage_account.file_storage_profiles.name
  access_tier          = "TransactionOptimized"
  for_each             = var.file_profiles

  name  = each.key
  quota = each.value.quota
}

resource "azurerm_private_endpoint" "profile_endpoint" {
  name                          = "stgintprofiles01-pep01"
  resource_group_name           = azurerm_resource_group.main_rg.name
  location                      = azurerm_resource_group.main_rg.location
  subnet_id                     = azurerm_subnet.internal_snet.id
  custom_network_interface_name = "devintprofiles01-nic"

  ip_configuration {
    name               = "stgintprofiles01-ip-private"
    private_ip_address = cidrhost(var.internal_snet_address_prefix, 21)
    subresource_name   = "file"
  }

  private_service_connection {
    name                           = "stgintprofiles01_psc"
    private_connection_resource_id = azurerm_storage_account.file_storage_profiles.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

resource "azurerm_private_dns_a_record" "dns_profile_share" {
  name                = "stgintprofiles01"
  zone_name           = azurerm_private_dns_zone.privatelink-file-dns.name
  resource_group_name = azurerm_resource_group.main_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.profile_endpoint.private_service_connection.0.private_ip_address]
}
#End Storage account for AVD profiles