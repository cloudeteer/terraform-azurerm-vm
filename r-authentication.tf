locals {
  admin_password = (
    var.authentication_type == "Password" ?
    coalesce(var.admin_password, one(random_password.this[*].result)) :
    null
  )

  admin_ssh_public_key = (
    var.authentication_type == "SSH" ?
    coalesce(var.admin_ssh_public_key, one(tls_private_key.this[*].public_key_openssh)) :
    null
  )

  admin_ssh_private_key = local.create_ssh_key_pair ? one(tls_private_key.this[*].private_key_openssh) : null
  create_password       = var.authentication_type == "Password" && var.admin_password == null
  create_ssh_key_pair   = var.authentication_type == "SSH" && var.admin_ssh_public_key == null
}

resource "random_password" "this" {
  count  = local.create_password ? 1 : 0
  length = 24
}

resource "tls_private_key" "this" {
  count     = local.create_ssh_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#trivy:ignore:avd-azu-0017
#trivy:ignore:avd-azu-0013
resource "azurerm_key_vault_secret" "this" {
  count = var.store_secret_in_key_vault ? 1 : 0

  name         = "${var.name}-${var.admin_username}-${lower(var.authentication_type)}"
  content_type = var.authentication_type
  key_vault_id = var.key_vault_id
  value        = coalesce(local.admin_password, local.admin_ssh_private_key)
}
