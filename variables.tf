# Permissions Groups
variable "rg_owner_group_id" {}
variable "rg_contributor_group_id" {}
variable "rg_reader_group_id" {}

# Networking VNET & SNET
variable "main_vnet_address_space" {}
variable "mgmt_snet_address_prefix" {}
variable "avd_snet_address_prefix" {}
variable "dmz_snet_address_prefix" {}
variable "internal_snet_address_prefix" {}

# Resource Tags
variable "tags" {}
variable "AVD_tags" {}
variable "AVD_shared_tags" {}

# Start storage.tf variables
variable "file_shares" {}
variable "file_profiles" {}
variable "file_shares_contributor_group_id" {}
variable "file_profiles_contributor_group_id" {}
# End storage.tf variables

# Start virtual-machines.tf variables
variable "virtual_machines" {
  type = list(object({
    name = string,
    size = string,
    source_image = optional(object({
      publisher = string,
      offer     = string,
      sku       = string,
      version   = string,
      }), {
      publisher = "MicrosoftWindowsServer",
      offer     = "WindowsServer",
      sku       = "2019-Datacenter",
      version   = "latest",
    })
    timezone                     = optional(string, "Central Standard Time"),
    patch_mode                   = optional(string, "Manual"),
    enable_automatic_updates     = optional(bool, false),
    auto_shutdown_enabled        = optional(bool, false),
    auto_shutdown_time           = optional(number),
    dmz                          = optional(bool, false),
    private_ip_suffix            = optional(number, null),
    additional_private_ip_suffix = optional(list(number), [0]),
    ou_path                      = string,
    import                       = optional(bool, false),
    import_disk                  = optional(string)
  }))
}
variable "sql_settings" {
  type = object({
    server_name           = string,
    sql_license_type      = optional(string, "PAYG"),
    sql_connectivity_port = optional(number, 1433),
    sql_connectivity_type = optional(string, "PRIVATE"),
    storage_disk_type     = optional(string, "NEW"),
    storage_workload_type = optional(string, "GENERAL"),
    data_disks = map(object({
      name                 = string,
      storage_account_type = string,
      create_option        = string,
      disk_size_gb         = number,
      lun                  = number,
      default_file_path    = string,
      caching              = string,
    })),
  })
}
# End virtual-machines.tf variables

# Start AVD variables
# Pool variables
variable "stg_workspace" {
  type        = string
  description = "Create Workspace for AVD pools"
  #default     = "Intertel-Staging"
}

variable "stg_workspace_friendly" {
  type        = string
  description = "The name seein in the client"
  #default     = "Intertel Staging"
}

variable "stg_workspace_description" {
  type        = string
  description = "Portal workspace discription"
  #default     = "Intertel Staging Workspace"
}

# Computer join account
variable "domain_name" {
  type        = string
  default     = "intertel.local"
  description = "Name of the domain to join"
}

variable "domain_user_upn" {
  type        = string
  default     = "svc.directoryservice" # do not include domain name as this is appended
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "host_pool" {}

# End AVD variables

# Start networking-nsg-rules.tf variables
variable "domain_controller_ips" {
  description = "list of IP addresses to domain controllers"
  type        = list(string)
}
variable "mgmt_ips" {
  description = "Map of management PC names and IP addresses"
  type = map(object({
    name = string
    ip   = string
  }))
}
variable "server_names" {
  description = "Names assigned to servers. These may need to be changed between environments (dev, staging, prod, etc)"
  type        = map(string)
}
variable "net_services" {
  description = "Map of network services associated with port numbers. Protocol is to help user determine how to set up rule. It is not used otherwise yet."
  type = map(object({
    protocol = string
    port     = list(string)
  }))
}
# End networking-nsg-rules.tf variables

# Start Cross Tenant Variables
variable "Ontellus-Tenant" {
  description = "Ontellus tenant ID"
  default     = "e69ffd5c-8131-4a50-ac19-b4123a1e5502"
}

variable "ONT-Dev1-SubID" {
  description = "Ontellus ONT-Dev1 subscription ID"
  default     = "ffe5c17f-a5cd-46d5-8137-b8c02ee481af"
}

variable "IntSocial-Dev1-SubID" {
  description = "RecordsX Technologies IntSocial-Dev1 Subscription ID"
  default     = "b4ac37ba-5332-4222-aa2c-98cee3fe80ae"
}

variable "RecordsX-Technologies-Tenant" {
  description = "RecordsX Technologies tenant ID"
  default     = "ea57dc1e-6e92-4b1b-8dcc-adbf3f40ef67"
}

variable "SP-Client-ID" {
  description = "Client ID for the Enterpries App"
  default     = "3f31972c-b59f-480d-b4f3-71d39043b74e"
}
variable "Ont-Prod1-SubID" {
  description = "Ontellus Ont-Prod1 subscription ID"
  default     = "58e2361d-344c-4e85-b45b-c7435e9e2a42"
}

# End Cross Tenant Variables