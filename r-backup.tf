locals {
  backup_recovery_vault_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[8] : null
  backup_resource_group_name = var.backup_policy_id != null ? split("/", var.backup_policy_id)[4] : null
}

resource "azurerm_backup_protected_vm" "this" {
  count = var.enable_backup_protected_vm ? 1 : 0

  resource_group_name = local.backup_resource_group_name

  backup_policy_id    = var.backup_policy_id
  recovery_vault_name = local.backup_recovery_vault_name
  source_vm_id        = local.virtual_machine.id
}
