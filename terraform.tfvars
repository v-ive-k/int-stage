# Start groups for access
rg_owner_group_id       = "d4bcbbaa-6acd-4f50-adb2-c5a652760149"
rg_contributor_group_id = "56dc3577-eec9-4016-899a-5b5c1b32eb1d"
rg_reader_group_id      = "e62744b0-8ba9-413c-b26b-89136a7d3fc6"

# Start networking-core.tf vairables
main_vnet_address_space      = ["10.239.88.0/22"]
mgmt_snet_address_prefix     = "10.239.91.0/27"
avd_snet_address_prefix      = "10.239.90.0/24"
dmz_snet_address_prefix      = "10.239.88.0/24"
internal_snet_address_prefix = "10.239.89.0/24"

# Resource Tags
tags = {
  "environment" : "staging"
  "managed by" : "terraform"
  "domain" : "intertel"
  "owner" : "Greg Johnson"
  "Migrate Project" : "INT-MigProject-01"
  #"Business Unit" : "Intertel"
}

AVD_tags = {
  "OffPeakConcurrency" : "0"
  "PeakConcurrency" : "4"
}

AVD_shared_tags = {
  "OffPeakConcurrency" : "1" # number that stay on after hours
  "PeakConcurrency" : "1"    # number that turns on at beginning of day
}

# Start storage.tf vairables
# Start storage private endpoints
# Start containers
file_shares = {
  clientapps : {
    quota = 100
  }
  codocuments : {
    quota = 1
  }
  emailattachments : {
    quota = 40
  }
  humanresources : {
    quota = 1
  }
  itdept : {
    quota = 1
  }
  netdata : {
    quota = 105
  }
  optifiles : {
    quota = 1
  }
  reportgeneration : {
    quota = 290
  }
  tloxml : {
    quota = 5
  }
}

file_profiles = {
  profiles01 : {
    quota = 100
  }
  mgmt : {
    quota = 5
  }
}
# End Containers
# Start Permissions
file_shares_contributor_group_id   = "6de4764c-52fa-465e-8acd-05111eb87817"
file_profiles_contributor_group_id = "dc7eb76a-c22b-4132-8ab8-57284ca410ed"
# End Permissions
# End storage.tf vairables

# Start virtual-machines.tf variables
virtual_machines = [
  {
    name                  = "STINB2-MGT01"
    size                  = "Standard_B2ms"
    auto_shutdown_enabled = true
    auto_shutdown_time    = 2000
    private_ip_suffix     = 51
    ou_path               = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
  },
  {
    name = "STINB2-SQL01"
    size = "Standard_B8ms"
    source_image = {
      publisher = "microsoftsqlserver",
      offer     = "sql2019-ws2019",
      sku       = "sqldev",
      version   = "latest",
    }
    private_ip_suffix = 52
    ou_path           = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
  },
  {
    name              = "ST-TFSServer"
    size              = "Standard_B2ms"
    private_ip_suffix = 101
    ou_path           = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
    import            = "true"
    import_disk       = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/STG-TFSSERVER-OsDisk01"
  },
  {
    name              = "ST-UTILSRV01"
    size              = "Standard_B2ms"
    private_ip_suffix = 102
    ou_path           = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
    import            = "true"
    import_disk       = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/STG-UTILSRV01-OSdisk-01"
  },
  {
    name              = "ST-UTILSRV03"
    size              = "Standard_B2ms"
    private_ip_suffix = 103
    ou_path           = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
    import            = "true"
    import_disk       = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/STG-UTILSRV03-OSDisk01"
  },
  {
    name                         = "ST-WEB01"
    size                         = "Standard_B2ms"
    private_ip_suffix            = 104
    additional_private_ip_suffix = [161, 162]
    ou_path                      = "OU=Staging,OU=Azure Servers,OU=Azure,DC=intertel,DC=local"
    dmz                          = true
    import                       = "true"
    import_disk                  = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/STG-INB2-WEB01-OSdisk-01"
  },
]

sql_settings = {
  server_name = "STINB2-SQL01",
  data_disks = {
    "data" = {
      name                 = "SQLVMDATA01",
      storage_account_type = "Premium_LRS",
      create_option        = "Empty",
      disk_size_gb         = 1000,
      lun                  = 1,
      default_file_path    = "F:\\SQLDATA",
      caching              = "ReadOnly",
    },
    "logs" = {
      name                 = "SQLVMLOGS",
      storage_account_type = "Standard_LRS",
      create_option        = "Empty",
      disk_size_gb         = 100,
      lun                  = 2,
      default_file_path    = "G:\\SQLLOG",
      caching              = "None",
    },
    "tempdb" = {
      name                 = "SQLVMTEMPDB",
      storage_account_type = "Premium_LRS",
      create_option        = "Empty",
      disk_size_gb         = 100,
      lun                  = 0,
      default_file_path    = "H:\\SQLTEMP",
      caching              = "ReadOnly",
    },
  }
}
# End virtual-machines.tf variables

# AVD and VM Host Join
domain_user_upn = "svc.directoryservice"
domain_name     = "intertel.local"

# AVD Workspace variables
stg_workspace             = "Intertel-Staging"
stg_workspace_friendly    = "Intertel Staging"
stg_workspace_description = "Intertel Staging Workspace"

# Host Pool variables
host_pool = [
  # Mgmt _Personal_ Host Pool
  {
    name                             = "STIN-AVD-MgP"
    display_name                     = "STAGING INTERTEL AVD Mgmt Personal"
    description                      = "AVD personal host pool for Intertel Mgmt"
    source_image                     = "AVD-INT-Mgmt-Win10-img"
    count                            = 2
    size                             = "Standard_B4ms"
    type                             = "Personal"
    load_balancer_type               = "Persistent"
    personal_desktop_assignment_type = "Automatic"
    #maximum_sessions_allowed          = 0
    custom_rdp_properties             = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;audiocapturemode:i:1;use multimon:i:1;camerastoredirect:s:;enablerdsaadauth:i:1;"
    timezone                          = "Central Standard Time"
    subnet                            = "mgmt_snet"
    ou_path                           = "OU=Staging,OU=IN-AVD-MgP,OU=Azure AVD,OU=Azure,DC=intertel,DC=local"
    user_group_desktop_virtualization = "2847240d-38f3-4bed-82de-d821af05904d"
  },

  # Mgmt _Shared_ Host Pool
  {
    name                              = "STIN-AVD-MgS"
    display_name                      = "STAGING INTERTEL AVD Mgmt Shared"
    description                       = "AVD shared host pool for Intertel Mgmt"
    source_image                      = "AVD-INT-Mgmt-Win10-img"
    count                             = 1
    size                              = "Standard_B2ms"
    type                              = "Pooled"
    load_balancer_type                = "BreadthFirst"
    maximum_sessions_allowed          = 12
    custom_rdp_properties             = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;audiocapturemode:i:1;use multimon:i:1;camerastoredirect:s:;enablerdsaadauth:i:1;"
    timezone                          = "Central Standard Time"
    subnet                            = "mgmt_snet"
    ou_path                           = "OU=Staging,OU=IN-AVD-MgS,OU=Azure AVD,OU=Azure,DC=intertel,DC=local"
    user_group_desktop_virtualization = "caf20592-47e9-4528-9e29-e2b39502657b"
  },

  # User Standard Shared Host Pool
  {
    name                              = "STIN-AVD-Std"
    display_name                      = "STAGING INTERTEL AVD Standard"
    description                       = "AVD pooled host pool for Intertel"
    source_image                      = "AVD-INT-Win10-img"
    count                             = 2
    size                              = "Standard_E8s_v5"
    type                              = "Pooled"
    load_balancer_type                = "BreadthFirst"
    maximum_sessions_allowed          = 12
    custom_rdp_properties             = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;audiocapturemode:i:1;use multimon:i:1;camerastoredirect:s:;enablerdsaadauth:i:1;"
    timezone                          = "Central Standard Time"
    subnet                            = "avd_snet"
    ou_path                           = "OU=Staging,OU=IN-AVD-STD01,OU=Azure AVD,OU=Azure,DC=intertel,DC=local"
    user_group_desktop_virtualization = "5d9b8f03-c823-4be9-8c6b-548547bf4c55"
  },

  # User Standard Personal Host Pool
  {
    name                             = "STIN-AVD-PER"
    display_name                     = "STAGING INTERTEL AVD Personal"
    description                      = "AVD personal host pool for Intertel"
    source_image                     = "AVD-INT-Win10-img"
    count                            = 1
    size                             = "Standard_B2ms"
    type                             = "Personal"
    load_balancer_type               = "Persistent"
    personal_desktop_assignment_type = "Automatic"
    #maximum_sessions_allowed          = 0
    custom_rdp_properties             = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;audiocapturemode:i:1;use multimon:i:1;camerastoredirect:s:;enablerdsaadauth:i:1;"
    timezone                          = "Central Standard Time"
    subnet                            = "avd_snet"
    ou_path                           = "OU=Staging,OU=IN-AVD-PER01,OU=Azure AVD,OU=Azure,DC=intertel,DC=local"
    user_group_desktop_virtualization = "956d17cb-382b-4a26-ad94-3f30c35b7383"
  }
]

# Start networking-nsg-rules.tf variables
domain_controller_ips = ["10.249.12.11", "10.249.12.12"]
mgmt_ips = {
  jeff_michou = {
    name = "CCA1-IT-001"
    ip   = "192.168.3.51"
  },
  ryan_tognarini = {
    name = "STL-RT01"
    ip   = "10.1.97.200"
  },
  tony_cooper = {
    name = "TCOOPER01"
    ip   = "10.1.97.10"
  },
  tony_cooper_vm = {
    name = "TCOOPER01-avd"
    ip   = "10.239.94.4/32"
  },
  mohamed_mohsen_avd = {
    name = "DVIN-AVD-DEV-2"
    ip   = "10.239.94.40/32"
  },
  michele_mcquietor = {
    name = "KIO1-RDM01"
    ip   = "10.249.64.55/32"
  }
}
server_names = {
  tfs = "ST-TFSServer",
  web = "ST-WEB01",
  sql = "STINB2-SQL01"
}
net_services = {
  dns = {
    protocol = "*"
    port     = ["53"]
  }
  global_catalog = {
    protocol = "Tcp"
    port     = ["3268", "3269"]
  }
  http = {
    protocol = "Tcp"
    port     = ["80", "443"]
  }
  kerberos = {
    protocol = "*"
    port     = ["88", "464"]
  }
  ldap = {
    protocol = "*"
    port     = ["389", "636"]
  }
  mssql_tcp = {
    protocol = "Tcp"
    port     = ["1433", "1434"]
  }
  mssql_udp = {
    protocol = "Udp"
    port     = ["1434"]
  }
  ntp = {
    protocol = "*"
    port     = ["123"]
  }
  rdp = {
    protocol = "*"
    port     = ["3389"]
  }
  rpc = {
    protocol = "*"
    port     = ["135", "49152-65535"]
  }
  samba = {
    protocol = "Tcp"
    port     = ["139"]
  }
  smb = {
    protocol = "Tcp"
    port     = ["445"]
  }
  tfsserver_custom = {
    protocol = "Tcp"
    port     = ["8080-8099"]
  }
}
# End networking-nsg-rules.tf variables

# Start Cross Tenant Variables
Ontellus-Tenant              = "e69ffd5c-8131-4a50-ac19-b4123a1e5502" # Not Found
ONT-Dev1-SubID               = "ffe5c17f-a5cd-46d5-8137-b8c02ee481af"
RecordsX-Technologies-Tenant = "ea57dc1e-6e92-4b1b-8dcc-adbf3f40ef67" # Not Found
IntSocial-Dev1-SubID         = "b4ac37ba-5332-4222-aa2c-98cee3fe80ae"  # Not Found
SP-Client-ID                 = "3f31972c-b59f-480d-b4f3-71d39043b74e"
Ont-Prod1-SubID              = "58e2361d-344c-4e85-b45b-c7435e9e2a42"
# End Cross Tenant Variables