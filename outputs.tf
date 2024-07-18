output "image" {
  value = local.image
}

output "admin_password" {
  value     = local.admin_password
  sensitive = true
}

output "admin_ssh_public_key" {
  value     = local.admin_ssh_public_key
  sensitive = true
}

output "admin_ssh_private_key" {
  value     = local.admin_ssh_private_key
  sensitive = true
}

output "key_vault_secret_id" {
  value = try(azurerm_key_vault_secret.this[0].id, null)
}
