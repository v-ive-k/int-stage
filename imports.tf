# This file includes imports of non-Terraform created resources to bring them under Terraform management. These entries can be removed after importing, or left in the file for archive purposes.

# ST-TFSSERVER ------------------------------
## DISK
import {
  to = azurerm_managed_disk.imported-disks["ST-TFSServer"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/ST-TFSServer-OsDisk-01"
}
## NIC
import {
  to = azurerm_network_interface.vm-nics["ST-TFSServer"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Network/networkInterfaces/st-tfsserver973"
}
## VM
import {
  to = azurerm_virtual_machine.imported-vms["ST-TFSServer"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/virtualMachines/ST-TFSServer"
}

# ST-UTILSRV01 ------------------------------
## DISK
import {
  to = azurerm_managed_disk.imported-disks["ST-UTILSRV01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/ST-UTILSRV01-OsDisk-01"
}
## NIC
import {
  to = azurerm_network_interface.vm-nics["ST-UTILSRV01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Network/networkInterfaces/st-utilsrv01301"
}
## VM
import {
  to = azurerm_virtual_machine.imported-vms["ST-UTILSRV01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/virtualMachines/ST-UTILSRV01"
}

# ST-UTILSRV03 ------------------------------
## DISK
import {
  to = azurerm_managed_disk.imported-disks["ST-UTILSRV03"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/ST-UTILSRV03-OsDisk-01"
}
## NIC
import {
  to = azurerm_network_interface.vm-nics["ST-UTILSRV03"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Network/networkInterfaces/st-utilsrv03919"
}
## VM
import {
  to = azurerm_virtual_machine.imported-vms["ST-UTILSRV03"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/virtualMachines/ST-UTILSRV03"
}

# ST-WEB01 ------------------------------
## DISK
import {
  to = azurerm_managed_disk.imported-disks["ST-WEB01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/disks/ST-WEB01-OSdisk-01"
}
## NIC
import {
  to = azurerm_network_interface.vm-nics["ST-WEB01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Network/networkInterfaces/st-web01849"
}
## VM
import {
  to = azurerm_virtual_machine.imported-vms["ST-WEB01"]
  id = "/subscriptions/ffe5c17f-a5cd-46d5-8137-b8c02ee481af/resourceGroups/int-staging-rg/providers/Microsoft.Compute/virtualMachines/ST-WEB01"
}

# Importing the migrated VMs into Terraform works, but it will initially give an error when recreating the NICs. It throws the error: "In order to delete the network interface, it must be dissociated from the resource." However it cannot be dissociated without another NIC associated with the VM first. So uncomment the section below and apply. Then go into Azure portal, manually dissociate the old NIC, associate the temp NIC for the VM created below, and apply again. This will fix the NICs. Once finished, comment the below out again and apply a final time to clean up the temp NICs.
# resource "azurerm_network_interface" "temp-vm-nics" {
#   for_each = {
#     for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine
#     if virtual_machine.import == true
#   }

#   name                = "${each.value.name}-temp-nic"
#   resource_group_name = azurerm_resource_group.main_rg.name
#   location            = azurerm_resource_group.main_rg.location

#   ip_configuration {
#     name                          = "${each.value.name}-temp-nic-ip"
#     subnet_id                     = each.value.dmz == true ? azurerm_subnet.dmz_snet.id : azurerm_subnet.internal_snet.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   tags = var.tags
# }