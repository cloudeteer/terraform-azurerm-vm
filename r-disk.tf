locals {
  data_disks = [
    for _index, element in var.data_disks :
    merge(
      element, {
        name = coalesce(
          element.name,
          format("disk-%s-%02.0f", trimprefix(var.name, "vm-"), sum([_index, 1]))
        )
      }
    )
  ]
}

resource "azurerm_managed_disk" "this" {
  for_each = { for element in local.data_disks : element.name => element }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  source_resource_id   = each.value.source_resource_id
  storage_account_type = each.value.storage_account_type
  zone                 = var.zone

  lifecycle {
    ignore_changes = [
      # The following properties are ignored to facilitate VM restore operations via Azure Backup:
      # - name, create_option, source_resource_id: These may be changed by Azure during restore, so ignoring them prevents unnecessary recreation of disks.
      # - tags["RSVaultBackup"]: This tag is managed by Azure Backup and may change independently.
      # Note: Renaming disks requires manual deletion of the old disk and creation of a new one, as Terraform will not automatically handle this due to ignore_changes.
      name,
      create_option,
      source_resource_id,
      tags["RSVaultBackup"]
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = { for element in local.data_disks : element.name => element }

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = local.virtual_machine.id
  lun                = each.value.lun
  caching            = each.value.caching
}
