resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = { for rule in local.nsg_rules : "${rule.network_security_group_name}_${rule.name}" => rule }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = try(each.value.source_port_range, null)
  source_port_ranges           = try(each.value.source_port_ranges, null)
  destination_port_range       = try(each.value.destination_port_range, null)
  destination_port_ranges      = try(each.value.destination_port_ranges, null)
  source_address_prefix        = try(each.value.source_address_prefix, null)
  source_address_prefixes      = try(each.value.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.destination_address_prefixes, null)
  resource_group_name          = each.value.resource_group_name
  network_security_group_name  = each.value.network_security_group_name
}

locals {
  # Common ports listed as groups of services. Can be used in SR rules in place of individual ports if desired.
  net_service_groups = {
    active_directory          = concat(var.net_services.dns.port, var.net_services.kerberos.port, var.net_services.ldap.port, var.net_services.ntp.port, var.net_services.rpc.port),
    active_directory_tcp_only = concat(var.net_services.global_catalog.port, var.net_services.samba.port, var.net_services.smb.port)
  }


  nsg_rules = [

    # Begin Mgmt Inbound -----------------------------
    {
      name                        = "${var.mgmt_ips.jeff_michou.name}_to_ALL"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.jeff_michou.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.mgmt_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.ryan_tognarini.name}_to_ALL"
      priority                    = 120
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.ryan_tognarini.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.mgmt_nsg.name
    },
    {
      name                        = "INBOUND_IMPLICIT_DENY"
      priority                    = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.mgmt_nsg.name
    },

    # Begin Mgmt Outbound -----------------------------
    # TBD

    # Begin DMZ Inbound -----------------------------
    {
      name                        = "MGMT_to_ALL"
      priority                    = 108
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_snet_address_prefix
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.jeff_michou.name}_to_ALL"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.jeff_michou.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.ryan_tognarini.name}_to_ALL"
      priority                    = 120
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.ryan_tognarini.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.tony_cooper_vm.name}_to_ALL_RDP"
      priority                    = 130
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.rdp.port
      source_address_prefix       = var.mgmt_ips.tony_cooper_vm.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "DCs_to_ALL_DS"
      priority                    = 310
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges     = local.net_service_groups.active_directory
      source_address_prefixes     = var.domain_controller_ips
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "DCs_to_ALL_DS_TCP_ONLY"
      priority                    = 311
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = local.net_service_groups.active_directory_tcp_only
      source_address_prefixes     = var.domain_controller_ips
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                         = "ALL_to_WEB01_HTTP"
      priority                     = 330
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = var.net_services.http.port
      source_address_prefix        = "*"
      destination_address_prefixes = azurerm_network_interface.vm-nics[var.server_names.web].private_ip_addresses
      resource_group_name          = azurerm_resource_group.main_rg.name
      network_security_group_name  = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "INBOUND_IMPLICIT_DENY"
      priority                    = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },

    # Begin DMZ Outbound -----------------------------
    {
      name                         = "DMZ_to_DCs_DS"
      priority                     = 310
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_ranges      = local.net_service_groups.active_directory
      source_address_prefix        = "*"
      destination_address_prefixes = var.domain_controller_ips
      resource_group_name          = azurerm_resource_group.main_rg.name
      network_security_group_name  = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                         = "DMZ_to_DCs_DS_TCP_ONLY"
      priority                     = 311
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = local.net_service_groups.active_directory_tcp_only
      source_address_prefix        = "*"
      destination_address_prefixes = var.domain_controller_ips
      resource_group_name          = azurerm_resource_group.main_rg.name
      network_security_group_name  = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "WEB01_to_SQL_MSSQL_TCP"
      priority                    = 330
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.mssql_tcp.port
      source_address_prefixes     = azurerm_network_interface.vm-nics[var.server_names.web].private_ip_addresses
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "DMZ_to_INTERNET_HTTP"
      priority                    = 1200
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.http.port
      source_address_prefix       = "*"
      destination_address_prefix  = "Internet"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },
    {
      name                        = "OUTBOUND_IMPLICIT_DENY"
      priority                    = 4096
      direction                   = "Outbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.dmz_nsg.name
    },

    # Begin Internal Inbound -----------------------------
    {
      name                        = "MGMT_to_ALL"
      priority                    = 108
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_snet_address_prefix
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.jeff_michou.name}_to_ALL"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.jeff_michou.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.ryan_tognarini.name}_to_ALL"
      priority                    = 120
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.ryan_tognarini.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.tony_cooper_vm.name}_to_ALL_RDP"
      priority                    = 130
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.rdp.port
      source_address_prefix       = var.mgmt_ips.tony_cooper_vm.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.tony_cooper_vm.name}_to_SQL_MSSQL"
      priority                    = 131
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.mssql_tcp.port
      source_address_prefix       = var.mgmt_ips.tony_cooper_vm.ip
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                         = "${var.mgmt_ips.tony_cooper_vm.name}_to_FS_SMB"
      priority                     = 132
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = concat(var.net_services.http.port, var.net_services.smb.port)
      source_address_prefix        = var.mgmt_ips.tony_cooper_vm.ip
      destination_address_prefixes = [azurerm_private_endpoint.file_endpoint.ip_configuration[0].private_ip_address, azurerm_private_endpoint.profile_endpoint.ip_configuration[0].private_ip_address]
      resource_group_name          = azurerm_resource_group.main_rg.name
      network_security_group_name  = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "INTERNAL_to_INTERNAL"
      priority                    = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.internal_snet_address_prefix
      destination_address_prefix  = var.internal_snet_address_prefix
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "WEB01_to_SQL_MSSQL"
      priority                    = 250
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.mssql_tcp.port
      source_address_prefixes     = azurerm_network_interface.vm-nics[var.server_names.web].private_ip_addresses
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                         = "AVD_to_FS_SMB"
      priority                     = 310
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_ranges      = concat(var.net_services.http.port, var.net_services.smb.port)
      source_address_prefix        = var.avd_snet_address_prefix
      destination_address_prefixes = [azurerm_private_endpoint.file_endpoint.ip_configuration[0].private_ip_address, azurerm_private_endpoint.profile_endpoint.ip_configuration[0].private_ip_address]
      resource_group_name          = azurerm_resource_group.main_rg.name
      network_security_group_name  = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "AVD_to_SQL_MSSQL"
      priority                    = 350
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.mssql_tcp.port
      source_address_prefix       = var.avd_snet_address_prefix
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "AVD_to_TFS_CUSTOM"
      priority                    = 360
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.tfsserver_custom.port
      source_address_prefix       = var.avd_snet_address_prefix
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.tfs].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.michele_mcquietor.name}_to_SQL_ALL"
      priority                    = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.michele_mcquietor.ip
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.mohamed_mohsen_avd.name}_to_SQL_MSSQL"
      priority                    = 305
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_ranges     = var.net_services.mssql_tcp.port
      source_address_prefix       = var.mgmt_ips.mohamed_mohsen_avd.ip
      destination_address_prefix  = azurerm_network_interface.vm-nics[var.server_names.sql].private_ip_address
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },
    {
      name                        = "INBOUND_IMPLICIT_DENY"
      priority                    = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.internal_nsg.name
    },

    # Begin Internal Outbound -----------------------------
    # TBD

    # Begin AVD Inbound -----------------------------
    {
      name                        = "MGMT_to_ALL"
      priority                    = 108
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_snet_address_prefix
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.avd_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.jeff_michou.name}_to_ALL"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.jeff_michou.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.avd_nsg.name
    },
    {
      name                        = "${var.mgmt_ips.ryan_tognarini.name}_to_ALL"
      priority                    = 120
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = var.mgmt_ips.ryan_tognarini.ip
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.avd_nsg.name
    },
    {
      name                        = "INBOUND_IMPLICIT_DENY"
      priority                    = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      resource_group_name         = azurerm_resource_group.main_rg.name
      network_security_group_name = azurerm_network_security_group.avd_nsg.name
    },

    # Begin AVD Outbound -----------------------------
    # TBD

  ]

}