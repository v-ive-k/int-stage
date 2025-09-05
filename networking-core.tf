# Create Vitual Network
resource "azurerm_virtual_network" "main_vnet" {
  name                = "intertel-staging-scus-vnet"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = var.main_vnet_address_space
  dns_servers         = ["10.249.12.11", "10.249.12.12"]
  tags                = var.tags
}

# Create Network Security Groups
resource "azurerm_network_security_group" "mgmt_nsg" {
  name                = "intertel-staging-mgmt-scus-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags                = var.tags
}

resource "azurerm_network_security_group" "avd_nsg" {
  name                = "intertel-staging-avd-scus-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags                = var.tags
}

resource "azurerm_network_security_group" "dmz_nsg" {
  name                = "intertel-staging-dmz-scus-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags                = var.tags
}

resource "azurerm_network_security_group" "internal_nsg" {
  name                = "intertel-staging-inernal-scus-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  tags                = var.tags
}

# Create Subnets
resource "azurerm_subnet" "mgmt_snet" {
  name                 = "intertel-staging-mgmt-scus-snet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.mgmt_snet_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]
}
resource "azurerm_subnet" "avd_snet" {
  name                 = "intertel-staging-avd-scus-snet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.avd_snet_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "dmz_snet" {
  name                 = "intertel-staging-dmz-scus-snet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.dmz_snet_address_prefix]
}

resource "azurerm_subnet" "internal_snet" {
  name                 = "intertel-staging-internal-scus-snet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = [var.internal_snet_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]
}

# Associate NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_association" {
  subnet_id                 = azurerm_subnet.mgmt_snet.id
  network_security_group_id = azurerm_network_security_group.mgmt_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "avd_nsg_association" {
  subnet_id                 = azurerm_subnet.avd_snet.id
  network_security_group_id = azurerm_network_security_group.avd_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "dmz_nsg_association" {
  subnet_id                 = azurerm_subnet.dmz_snet.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "internal_nsg_association" {
  subnet_id                 = azurerm_subnet.internal_snet.id
  network_security_group_id = azurerm_network_security_group.internal_nsg.id
}

# Associate route table to subnets
resource "azurerm_subnet_route_table_association" "mgmt_snet_rt_association" {
  subnet_id      = azurerm_subnet.mgmt_snet.id
  route_table_id = data.azurerm_route_table.dev-scus-rt.id
}

resource "azurerm_subnet_route_table_association" "avd_snet_rt_association" {
  subnet_id      = azurerm_subnet.avd_snet.id
  route_table_id = data.azurerm_route_table.dev-scus-rt.id
}

resource "azurerm_subnet_route_table_association" "dmz_snet_rt_association" {
  subnet_id      = azurerm_subnet.dmz_snet.id
  route_table_id = data.azurerm_route_table.dev-scus-rt.id
}

resource "azurerm_subnet_route_table_association" "internal_snet_rt_association" {
  subnet_id      = azurerm_subnet.internal_snet.id
  route_table_id = data.azurerm_route_table.dev-scus-rt.id
}

# Add peering to it-prod-scus-vnet

resource "azurerm_virtual_network_peering" "main_vnet_it_vnet" {
  name                      = "intertel-staging-scus-vnet-TO-it-prod-scus-vnet"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

resource "azurerm_virtual_network_peering" "prod_it_vnet_main_vnet" {
  provider                  = azurerm.prodcution
  name                      = "it-prod-scus-vnet-TO-intertel-staging-scus-vnet"
  resource_group_name       = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

# Add peering to networking-dev-rg

resource "azurerm_virtual_network_peering" "main_vnet_network-dev-scus-vnet" {
  name                      = "intertel-staging-scus-vnet-TO-network-dev-scus-vnet"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.network-dev-scus-vnet.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

resource "azurerm_virtual_network_peering" "network-dev-scus-vnet_main_vnet" {
  name                      = "network-dev-scus-vnet-TO-intertel-staging-scus-vnet"
  resource_group_name       = data.azurerm_virtual_network.network-dev-scus-vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.network-dev-scus-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

# Add peering to MR8-Prod-SCUS-VNet

resource "azurerm_virtual_network_peering" "main_vnet_MR8-Prod-SCUS-VNet" {
  name                      = "intertel-staging-scus-vnet-TO-MR8-Prod-SCUS-VNet"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.MR8-Prod-SCUS-VNet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

resource "azurerm_virtual_network_peering" "MR8-Prod-SCUS-VNet_main_vnet" {
  provider                  = azurerm.prodcution
  name                      = "MR8-Prod-SCUS-VNet-TO-intertel-staging-scus-vnet"
  resource_group_name       = data.azurerm_virtual_network.MR8-Prod-SCUS-VNet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.MR8-Prod-SCUS-VNet.name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

# Add peering to intertel-prod-scus-vnet in int-prod-rg
resource "azurerm_virtual_network_peering" "intertel-staging-scus-vnet_TO_intertel-prod-scus-vnet" {
  name                      = "intertel-staging-scus-vnet_TO_intertel-prod-scus-vnet"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.intertel-prod-scus-vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

resource "azurerm_virtual_network_peering" "intertel-prod-scus-vnet_TO_intertel-staging-scus-vnet" {
  provider                  = azurerm.prodcution
  name                      = "intertel-prod-scus-vnet_TO_intertel-staging-scus-vnet"
  resource_group_name       = data.azurerm_virtual_network.intertel-prod-scus-vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.intertel-prod-scus-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

# Add peering to intertel-dev-scus-vnet in int-dev-rg
resource "azurerm_virtual_network_peering" "intertel-staging-scus-vnet_TO_intertel-dev-scus-vnet" {
  name                      = "intertel-staging-scus-vnet_TO_intertel-dev-scus-vnet"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.intertel-dev-scus-vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

resource "azurerm_virtual_network_peering" "intertel-dev-scus-vnet_TO_intertel-staging-scus-vnet" {
  #provider = 
  name                      = "intertel-dev-scus-vnet_TO_intertel-staging-scus-vnet"
  resource_group_name       = data.azurerm_virtual_network.intertel-dev-scus-vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.intertel-dev-scus-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.main_vnet.id
  allow_forwarded_traffic   = true
  timeouts {
    create = "5m"
    update = "5m"
    read   = "5m"
  }
}

# Add peering to social-devstaging-scus-vnet in RecordsX Technologies tenant for ONT-Prod1 IT-vnet
resource "azurerm_virtual_network_peering" "ont_prod1_it_vnet_social_staging_vnet" {
  provider                     = azurerm.OntellusProd1
  name                         = "it-prod-scus-vnet-TO-social-staging-scus-vnet"
  resource_group_name          = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.social-staging-scus-vnet.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vnet_social_staging_vnet_ont_prod1_it" {
  provider                     = azurerm.RecordsXTenant
  name                         = "social-staging-scus-vnet-TO-it-prod-scus-vnet"
  resource_group_name          = data.azurerm_virtual_network.social-staging-scus-vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.social-staging-scus-vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.IT-Prod-SCUS-VNet.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network_peering.ont_prod1_it_vnet_social_staging_vnet]
}
# end peering to social-staging-scus-vnet

# Add peering to social-staging-scus-vnet in RecordsX Technologies tenant for 
resource "azurerm_virtual_network_peering" "main_vnet-social_social_vnet" {
  provider                     = azurerm.OntellusTenant
  name                         = "intertel-staging-scus-vnet-TO-social-staging-scus-vnet"
  resource_group_name          = azurerm_resource_group.main_rg.name
  virtual_network_name         = azurerm_virtual_network.main_vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.social-staging-scus-vnet.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "social_dev_vnet-main_vnet" {
  provider                     = azurerm.RecordsXTenant
  name                         = "social-staging-scus-vnet-TO-intertel-staging-scus-vnet"
  resource_group_name          = data.azurerm_virtual_network.social-staging-scus-vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.social-staging-scus-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.main_vnet.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network_peering.main_vnet-social_social_vnet]
}
# end peering to social-dev-scus-vnet

# Public IP addresses

resource "azurerm_public_ip" "int-staging-ngw-pip01" {
  name                = "int-staging-ngw-scus-pip01"
  resource_group_name = data.azurerm_virtual_network.network-dev-scus-vnet.resource_group_name
  location            = data.azurerm_virtual_network.network-dev-scus-vnet.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# NAT Gateway using static public IP to allow whitelisting on provider services and attach to AVD/Internal snet

resource "azurerm_nat_gateway" "int-staging-ngw" {
  name                    = "ont-dev1-int-staging-scus-ngw"
  location                = azurerm_resource_group.main_rg.location
  resource_group_name     = azurerm_resource_group.main_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "int-staging-ngw" {
  nat_gateway_id       = azurerm_nat_gateway.int-staging-ngw.id
  public_ip_address_id = azurerm_public_ip.int-staging-ngw-pip01.id
}

resource "azurerm_subnet_nat_gateway_association" "int-staging-mgmt-ngw" {
  subnet_id      = azurerm_subnet.mgmt_snet.id
  nat_gateway_id = azurerm_nat_gateway.int-staging-ngw.id
}

resource "azurerm_subnet_nat_gateway_association" "int-staging-avd-ngw" {
  subnet_id      = azurerm_subnet.avd_snet.id
  nat_gateway_id = azurerm_nat_gateway.int-staging-ngw.id
}

resource "azurerm_subnet_nat_gateway_association" "int-staging-internal-ngw" {
  subnet_id      = azurerm_subnet.internal_snet.id
  nat_gateway_id = azurerm_nat_gateway.int-staging-ngw.id
}

# Azure private DNS Zone

resource "azurerm_private_dns_zone" "privatelink-file-dns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.main_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink-file-dns-vnet" {
  name                  = "file"
  resource_group_name   = azurerm_resource_group.main_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink-file-dns.name
  virtual_network_id    = azurerm_virtual_network.main_vnet.id
}