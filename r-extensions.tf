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

  for_each = {
    for element in
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

resource "azurerm_virtual_machine_extension" "entra_id_login" {

  count = var.entra_id_login.enabled ? 1 : 0

  name                 = "EntraIDLogin"
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = local.is_linux ? "AADSSHLoginForLinux" : "AADLoginForWindows"
  type_handler_version = "1.0"
  virtual_machine_id   = local.virtual_machine.id

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "entra_id_login_admin" {
  for_each = (
    var.entra_id_login.enabled
    ? toset(concat(var.entra_id_login.principal_ids, var.entra_id_login.admin_login_principal_ids))
    : []
  )

  principal_id         = each.value
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = local.virtual_machine.id
}

resource "azurerm_role_assignment" "entra_id_login_user" {
  for_each = (
    var.entra_id_login.enabled ? toset(var.entra_id_login.user_login_principal_ids) : []
  )

  principal_id         = each.value
  role_definition_name = "Virtual Machine User Login"
  scope                = local.virtual_machine.id
}


resource "azurerm_virtual_machine_extension" "domain_join" {
  count = var.domain_join.enabled ? 1 : 0

  name                       = "DomainJoin"
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = false

  virtual_machine_id = local.virtual_machine.id

  settings = jsonencode({
    Name    = var.domain_join.domain_name,
    OUPath  = var.domain_join.ou_path,
    User    = var.domain_join.join_user,
    Restart = var.domain_join.restart,
    Options = var.domain_join.options
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    # The Domain Join extension restarts the virtual machine, which may conflict
    # with the installation of other extensions. To avoid such conflicts, we add
    # a dependency on the Domain Join extension.
    azurerm_virtual_machine_extension.entra_id_login,
    azurerm_virtual_machine_extension.this
  ]
}
