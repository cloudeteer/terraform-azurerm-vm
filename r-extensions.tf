locals {
  common_extensions = [
    {
      name                       = "NetworkWatcherAgent"
      publisher                  = "Microsoft.Azure.NetworkWatcher"
      type                       = format("NetworkWatcherAgent%s", local.image_full.operating_system)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
    {
      name                       = "AzureMonitorAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = format("AzureMonitor%sAgent", local.image_full.operating_system)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
    {
      name                       = "AzurePolicy"
      publisher                  = "Microsoft.GuestConfiguration"
      type                       = format("Configurationfor%s", local.image_full.operating_system)
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
    },
  ]

  windows_extenstion = [
    {
      name                       = "AntiMalware"
      publisher                  = "Microsoft.Azure.Security"
      type                       = "IaaSAntimalware"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = false
    },
  ]

  linux_extensions = []
}

resource "azurerm_virtual_machine_extension" "this" {

  for_each = { for element in
    concat(
      local.common_extensions,
      (local.is_windows ? local.windows_extenstion : []),
      (local.is_linux ? local.linux_extensions : [])
    ) :
    element.name => element if contains(var.extensions, element.name) && var.allow_extension_operations
  }

  virtual_machine_id = local.virtual_machine.id

  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled  = each.value.automatic_upgrade_enabled
  name                       = each.value.name
  publisher                  = each.value.publisher
  type                       = each.value.type
  type_handler_version       = each.value.type_handler_version

  lifecycle {
    ignore_changes = [tags]
  }
}
