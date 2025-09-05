# This is where Intertel servers are created.  There is additional VMs for AVD pools in the avd.tf

# Proximity Placement Grorp
resource "azurerm_proximity_placement_group" "int-stg-ppg" {
  name                = "int-stg-ppg"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  allowed_vm_sizes    = ["Standard_B2ms", "Standard_B8ms", "Standard_E8s_v5"]

  tags = var.tags
}
# Network interfaces
resource "azurerm_network_interface" "vm-nics" {
  for_each = { for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine }

  name                = "${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location

  ip_configuration {
    name                          = "${each.value.name}-nic-ip"
    subnet_id                     = each.value.dmz == true ? azurerm_subnet.dmz_snet.id : azurerm_subnet.internal_snet.id
    private_ip_address_allocation = each.value.private_ip_suffix != null ? "Static" : "Dynamic"
    private_ip_address            = each.value.private_ip_suffix != null ? cidrhost(each.value.dmz == true ? var.dmz_snet_address_prefix : var.internal_snet_address_prefix, each.value.private_ip_suffix) : null
    primary                       = true
  }

  dynamic "ip_configuration" {
    iterator = additional_ip
    for_each = {
      for ip_suffix in each.value.additional_private_ip_suffix : index(each.value.additional_private_ip_suffix, ip_suffix) + 1 => ip_suffix
      if ip_suffix != 0
    }
    content {
      name                          = "${each.value.name}-additional-ip-${additional_ip.key}"
      subnet_id                     = each.value.dmz == true ? azurerm_subnet.dmz_snet.id : azurerm_subnet.internal_snet.id
      private_ip_address_allocation = "Static"
      private_ip_address            = cidrhost(each.value.dmz == true ? var.dmz_snet_address_prefix : var.internal_snet_address_prefix, additional_ip.value)
    }

  }

  tags = var.tags
}

# Disks for imported virtual machines
resource "azurerm_managed_disk" "imported-disks" {
  for_each = {
    for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
    if virtual_machine.import == true
  }

  name                 = each.value.name == "ST-WEB01" ? "${each.value.name}-OSdisk-01" : "${each.value.name}-OsDisk-01"
  resource_group_name  = azurerm_resource_group.main_rg.name
  location             = azurerm_resource_group.main_rg.location
  create_option        = "Copy"
  source_resource_id   = each.value.import_disk
  storage_account_type = "Premium_LRS"
  hyper_v_generation   = each.value.name == "ST-TFSServer" ? "V1" : "V2"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      os_type
    ]
  }
}

# Virtual machines imported into Terraform
resource "azurerm_virtual_machine" "imported-vms" {

  for_each = {
    for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
    if virtual_machine.import == true
  }

  name                = each.value.name
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = azurerm_resource_group.main_rg.location
  vm_size             = each.value.size

  os_profile {
    computer_name  = each.value.name
    admin_username = "ONTAdmin"
    admin_password = data.azurerm_key_vault_secret.ontadmin.value
  }

  proximity_placement_group_id = azurerm_proximity_placement_group.int-stg-ppg.id

  network_interface_ids = [
    azurerm_network_interface.vm-nics[each.value.name].id
  ]

  storage_os_disk {
    name            = azurerm_managed_disk.imported-disks[each.value.name].name
    caching         = "ReadWrite"
    create_option   = "Attach"
    managed_disk_id = azurerm_managed_disk.imported-disks[each.value.name].id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      os_profile,
      boot_diagnostics
    ]
  }
  depends_on = [
    azurerm_managed_disk.imported-disks,
    azurerm_network_interface.vm-nics
  ]
}

# Virtual machines provisioned by Terraform
resource "azurerm_windows_virtual_machine" "vms" {
  for_each = {
    for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
    if virtual_machine.import == false
  }

  name                         = each.value.name
  resource_group_name          = azurerm_resource_group.main_rg.name
  location                     = azurerm_resource_group.main_rg.location
  size                         = each.value.size
  admin_username               = "ONTAdmin"
  admin_password               = data.azurerm_key_vault_secret.ontadmin.value
  patch_mode                   = each.value.patch_mode
  enable_automatic_updates     = each.value.enable_automatic_updates
  timezone                     = each.value.timezone
  proximity_placement_group_id = azurerm_proximity_placement_group.int-stg-ppg.id

  network_interface_ids = [
    azurerm_network_interface.vm-nics[each.value.name].id
  ]

  os_disk {
    name                 = "${each.value.name}-disk-os"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = each.value.source_image.publisher
    offer     = each.value.source_image.offer
    sku       = each.value.source_image.sku
    version   = each.value.source_image.version
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      admin_password,
      identity
    ]
  }
}

resource "azurerm_virtual_machine_extension" "vms-domain-join" {
  for_each = {
    for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
    #if virtual_machine.import == false # uncomment to prevent imported machines from automatically joining the domain
  }

  name                       = "${each.value.name}-domain-join"
  virtual_machine_id         = try(azurerm_windows_virtual_machine.vms[each.value.name].id, azurerm_virtual_machine.imported-vms[each.value.name].id)
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
    azurerm_windows_virtual_machine.vms,
    azurerm_virtual_machine.imported-vms
  ]
}

# Create disks for SQL and attach to VM
resource "azurerm_managed_disk" "vm-sql-disks" {
  for_each = var.sql_settings.data_disks

  name                 = "${var.sql_settings.server_name}-disk-${each.value.name}"
  resource_group_name  = azurerm_resource_group.main_rg.name
  location             = azurerm_resource_group.main_rg.location
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-sql-disks-attach" {
  for_each = var.sql_settings.data_disks

  managed_disk_id    = azurerm_managed_disk.vm-sql-disks[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vms[var.sql_settings.server_name].id
  lun                = each.value.lun
  caching            = each.value.caching
}

# SQL server VM
resource "azurerm_mssql_virtual_machine" "vm-sql" {
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.vm-sql-disks-attach,
    azurerm_windows_virtual_machine.vms,
    azurerm_virtual_machine.imported-vms
  ]

  virtual_machine_id    = azurerm_windows_virtual_machine.vms[var.sql_settings.server_name].id
  sql_license_type      = var.sql_settings.sql_license_type
  sql_connectivity_port = var.sql_settings.sql_connectivity_port
  sql_connectivity_type = var.sql_settings.sql_connectivity_type

  storage_configuration {
    disk_type             = var.sql_settings.storage_disk_type
    storage_workload_type = var.sql_settings.storage_workload_type
    data_settings {
      default_file_path = var.sql_settings.data_disks.data.default_file_path
      luns              = [var.sql_settings.data_disks.data.lun]
    }
    log_settings {
      default_file_path = var.sql_settings.data_disks.logs.default_file_path
      luns              = [var.sql_settings.data_disks.logs.lun]
    }
    temp_db_settings {
      default_file_path = var.sql_settings.data_disks.tempdb.default_file_path
      luns              = [var.sql_settings.data_disks.tempdb.lun]
    }
  }
}

# Auto shutdown settings
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm-autoshutdown" {
  for_each = {
    for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
    if virtual_machine.auto_shutdown_enabled
  }

  virtual_machine_id    = azurerm_windows_virtual_machine.vms[each.value.name].id
  location              = azurerm_resource_group.main_rg.location
  enabled               = each.value.auto_shutdown_enabled
  daily_recurrence_time = each.value.auto_shutdown_time
  timezone              = each.value.timezone

  notification_settings {
    enabled = false
  }

  tags = var.tags
}