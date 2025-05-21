locals {
  create_identity = (
    strcontains(try(var.identity.type, ""), "UserAssigned") &&
    length(try(coalescelist(var.identity.identity_ids, []), [])) == 0
  )
}

resource "azurerm_user_assigned_identity" "this" {
  count = local.create_identity ? 1 : 0

  name                = "id-${trimprefix(var.name, "vm-")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "entra_id_login" {
  for_each = var.entra_id_login.enabled ? toset(var.entra_id_login.principal_ids) : []

  principal_id         = each.value
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = local.virtual_machine.id
}
