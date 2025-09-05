# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "stg_workspace" {
  name                = var.stg_workspace
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  friendly_name       = var.stg_workspace_friendly
  description         = var.stg_workspace_description
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags["MessageBody"], tags["MessageTitle"]
    ]
  }
}

# Host Pools Begin
locals {

  # Iterate over each pool inside of var.host_pool, and based on the pool's 'count' value, creates a new list that adds each anticipated VM as 'host'. This is necessary because you cannot combine 'for_each' and 'count' in a single resource definition, so they must be flattened into a single list.
  host_pool_hosts = flatten([
    for host_pool in var.host_pool : [
      for iterator in range(host_pool.count) : merge(host_pool, { host = "${host_pool.name}-${iterator + 1}" })
    ]
  ])

  subnets = {
    mgmt_snet = azurerm_subnet.mgmt_snet
    dmz_snet  = azurerm_subnet.dmz_snet
    avd_snet  = azurerm_subnet.avd_snet
  }

  source_images = {
    AVD-INT-Win10-img      = data.azurerm_shared_image.AVD-INT-Win10-img
    AVD-INT-Mgmt-Win10-img = data.azurerm_shared_image.AVD-INT-Mgmt-Win10-img
  }

}

resource "azurerm_virtual_desktop_host_pool" "pooled_host_pool" {
  for_each = { for pool in var.host_pool : pool.name => pool }

  resource_group_name              = azurerm_resource_group.main_rg.name
  location                         = azurerm_resource_group.main_rg.location
  name                             = each.value.name
  friendly_name                    = each.value.name
  description                      = each.value.description
  type                             = each.value.type
  load_balancer_type               = each.value.load_balancer_type
  personal_desktop_assignment_type = try(each.value.personal_desktop_assignment_type, null)
  maximum_sessions_allowed         = try(each.value.maximum_sessions_allowed, null)
  custom_rdp_properties            = each.value.custom_rdp_properties
  validate_environment             = true
  start_vm_on_connect              = true
  tags                             = merge(var.tags, var.AVD_shared_tags)
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "pooled_host_pool_registration" {
  for_each = { for pool in var.host_pool : pool.name => pool }

  hostpool_id     = azurerm_virtual_desktop_host_pool.pooled_host_pool[each.value.name].id
  expiration_date = timeadd(timestamp(), "720h")

  lifecycle {
    ignore_changes = [
      expiration_date
    ]
  }
}

resource "azurerm_virtual_desktop_application_group" "pooled_host_pool_dag" {
  for_each = { for pool in var.host_pool : pool.name => pool }

  resource_group_name          = azurerm_resource_group.main_rg.name
  location                     = azurerm_resource_group.main_rg.location
  host_pool_id                 = azurerm_virtual_desktop_host_pool.pooled_host_pool[each.value.name].id
  name                         = "${each.value.name}-dag"
  friendly_name                = "${each.value.name}-dag"
  default_desktop_display_name = each.value.display_name
  description                  = "Desktop application group for ${each.value.name}"
  type                         = "Desktop"

  depends_on = [
    azurerm_virtual_desktop_host_pool.pooled_host_pool,
    azurerm_virtual_desktop_workspace.stg_workspace
  ]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "pooled_host_pool_dag_ws_connect" {
  for_each = { for pool in var.host_pool : pool.name => pool }

  application_group_id = azurerm_virtual_desktop_application_group.pooled_host_pool_dag[each.value.name].id
  workspace_id         = azurerm_virtual_desktop_workspace.stg_workspace.id
}

resource "azurerm_network_interface" "pooled_host_pool_vm_nics" {
  for_each = { for host in local.host_pool_hosts : host.host => host }

  name                = "${each.value.host}-nic"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location

  ip_configuration {
    name                          = "${each.value.host}-nic-ip"
    subnet_id                     = lookup(local.subnets, each.value.subnet, "avd_snet").id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "pooled_host_pool_vms" {
  for_each = { for host in local.host_pool_hosts : host.host => host }

  name                         = each.value.host
  resource_group_name          = azurerm_resource_group.main_rg.name
  location                     = azurerm_resource_group.main_rg.location
  size                         = each.value.size
  admin_username               = "ONTAdmin"
  admin_password               = data.azurerm_key_vault_secret.ontadmin.value
  timezone                     = each.value.timezone
  provision_vm_agent           = true
  proximity_placement_group_id = azurerm_proximity_placement_group.int-stg-ppg.id

  network_interface_ids = [
    azurerm_network_interface.pooled_host_pool_vm_nics[each.value.host].id
  ]

  os_disk {
    name                 = lower(each.value.host)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_id = lookup(local.source_images, each.value.source_image, "AVD-INT-Win10-img").id

  lifecycle {
    ignore_changes = [
      tags["Offline"]
    ]
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "pooled_host_pool_domain_join" {
  for_each = { for host in local.host_pool_hosts : host.host => host }

  name                       = "${each.value.host}-domain-join"
  virtual_machine_id         = azurerm_windows_virtual_machine.pooled_host_pool_vms[each.value.host].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${each.value.ou_path}",
      "User": "${var.domain_user_upn}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.intertel-svc-directoryservice.value}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_windows_virtual_machine.pooled_host_pool_vms
  ]
}

resource "azurerm_virtual_machine_extension" "pooled_host_pool_dsc" {
  for_each = { for host in local.host_pool_hosts : host.host => host }

  name                       = "${each.value.host}-dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.pooled_host_pool_vms[each.value.host].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.pooled_host_pool[each.value.name].name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.pooled_host_pool_registration[each.value.name].token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.pooled_host_pool_domain_join,
    azurerm_virtual_desktop_host_pool.pooled_host_pool,
    azurerm_virtual_desktop_host_pool_registration_info.pooled_host_pool_registration
  ]
}

resource "azurerm_role_assignment" "pooled_host_pool_role_assign" {
  for_each = { for pool in var.host_pool : pool.name => pool }

  scope                = azurerm_virtual_desktop_application_group.pooled_host_pool_dag[each.value.name].id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = each.value.user_group_desktop_virtualization
}
# Pooled Host Pool End