# 2023-09-28 Moving AVD resources to accommodate for changes to AVD pools (from one to many)
moved {
  from = azurerm_virtual_desktop_host_pool.pooled_host_pool
  to   = azurerm_virtual_desktop_host_pool.pooled_host_pool["STIN-AVD-Std"]
}
moved {
  from = azurerm_virtual_desktop_host_pool_registration_info.pooled_host_pool_registration
  to   = azurerm_virtual_desktop_host_pool_registration_info.pooled_host_pool_registration["STIN-AVD-Std"]
}
moved {
  from = azurerm_virtual_desktop_application_group.pooled_host_pool_dag
  to   = azurerm_virtual_desktop_application_group.pooled_host_pool_dag["STIN-AVD-Std"]
}
moved {
  from = azurerm_virtual_desktop_workspace_application_group_association.pooled_host_pool_dag_ws_connect
  to   = azurerm_virtual_desktop_workspace_application_group_association.pooled_host_pool_dag_ws_connect["STIN-AVD-Std"]
}
moved {
  from = azurerm_network_interface.pooled_host_pool_vm_nics[0]
  to   = azurerm_network_interface.pooled_host_pool_vm_nics["STIN-AVD-Std-1"]
}
moved {
  from = azurerm_network_interface.pooled_host_pool_vm_nics[1]
  to   = azurerm_network_interface.pooled_host_pool_vm_nics["STIN-AVD-Std-2"]
}
moved {
  from = azurerm_network_interface.pooled_host_pool_vm_nics[2]
  to   = azurerm_network_interface.pooled_host_pool_vm_nics["STIN-AVD-Std-3"]  # NOT Found
}
moved {
  from = azurerm_windows_virtual_machine.pooled_host_pool_vms[0]
  to   = azurerm_windows_virtual_machine.pooled_host_pool_vms["STIN-AVD-Std-1"]
}
moved {
  from = azurerm_windows_virtual_machine.pooled_host_pool_vms[1]
  to   = azurerm_windows_virtual_machine.pooled_host_pool_vms["STIN-AVD-Std-2"]
}
moved {
  from = azurerm_windows_virtual_machine.pooled_host_pool_vms[2]
  to   = azurerm_windows_virtual_machine.pooled_host_pool_vms["STIN-AVD-Std-3"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_domain_join[0]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_domain_join["STIN-AVD-Std-1"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_domain_join[1]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_domain_join["STIN-AVD-Std-2"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_domain_join[2]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_domain_join["STIN-AVD-Std-3"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_dsc[0]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_dsc["STIN-AVD-Std-1"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_dsc[1]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_dsc["STIN-AVD-Std-2"]
}
moved {
  from = azurerm_virtual_machine_extension.pooled_host_pool_dsc[2]
  to   = azurerm_virtual_machine_extension.pooled_host_pool_dsc["STIN-AVD-Std-3"]
}
moved {
  from = azurerm_role_assignment.pooled_host_pool_role_assign
  to   = azurerm_role_assignment.pooled_host_pool_role_assign["STIN-AVD-Std"]
}