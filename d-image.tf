locals {
  image = (
    length(split(":", var.image)) == 4 ?
    {
      publisher = split(":", var.image)[0]
      offer     = split(":", var.image)[1]
      sku       = split(":", var.image)[2]
      version   = split(":", var.image)[3]
    } :
    local.azure_quickstart_templates[index(local.azure_quickstart_templates[*].urnAlias, var.image)]
  )

  image_full = merge(
    local.image,
    {
      architecture = coalesce(
        try(local.image.architecture, null),
        var.architecture,
        try(local.virtual_machine_image.properties.architecture, null)
      )
      operating_system = coalesce(
        try(local.image.operating_system, null),
        var.operating_system,
        try(local.virtual_machine_image.properties.osDiskImage.operatingSystem,
        null)
      )
    }
  )

  virtual_machine_image = (
    length(data.azapi_resource.virtual_machine_image) > 0 ?
    jsondecode(one(data.azapi_resource.virtual_machine_image[*].output)) :
    null
  )

  virtual_machine_image_id = (
    length(local.virtual_machine_images) > 0 ?
    element(local.virtual_machine_images, length(local.virtual_machine_images) - 1).id :
    format(
      "/subscriptions/%s/providers/Microsoft.Compute/locations/%s/publishers/%s/artifacttypes/vmimage/offers/%s/skus/%s/versions/%s",
      one(data.azapi_client_config.current[*].subscription_id),
      var.location,
      local.image.publisher,
      local.image.offer,
      local.image.sku,
      local.image.version,
    )
  )

  virtual_machine_images = (
    length(data.azapi_resource_list.virtual_machine_images) > 0 ?
    jsondecode(one(data.azapi_resource_list.virtual_machine_images[*].output)) :
    []
  )

  azure_quickstart_templates = flatten([
    for operating_system, quick_start_template in jsondecode(file("${path.module}/azure_common_images.json")).outputs.aliases.value : [
      for alias_name, alias in quick_start_template : merge(alias, {
        urnAlias         = alias_name,
        urn              = join(":", [alias.publisher, alias.offer, alias.sku, alias.version]),
        operating_system = operating_system
      })
    ]
  ])

  is_image_version_determination_required    = local.image.version == "latest"
  is_linux                                   = local.image_full.operating_system == "Linux"
  is_operating_system_determination_required = var.operating_system == null && !can(local.image.operating_system)
  is_architecture_determination_required     = var.architecture == null && !can(local.image.architecture)
  is_windows                                 = local.image_full.operating_system == "Windows"
}

data "azapi_client_config" "current" {
  count = (
    local.is_architecture_determination_required ||
    local.is_operating_system_determination_required ||
    local.is_image_version_determination_required ? 1 : 0
  )
}

data "azapi_resource_list" "virtual_machine_images" {
  # https://learn.microsoft.com/en-us/rest/api/compute/virtual-machine-images/list

  count = (
    local.is_architecture_determination_required ||
    local.is_operating_system_determination_required &&
    local.is_image_version_determination_required ? 1 : 0
  )

  parent_id = format(
    "/subscriptions/%s/providers/Microsoft.Compute/locations/%s/publishers/%s/artifacttypes/vmimage/offers/%s/skus/%s",
    one(data.azapi_client_config.current[*].subscription_id),
    var.location,
    local.image.publisher,
    local.image.offer,
    local.image.sku
  )

  type = "Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/versions@2022-03-01"

  response_export_values = ["*"]
}

data "azapi_resource" "virtual_machine_image" {
  # https://learn.microsoft.com/en-us/rest/api/compute/virtual-machine-images/get

  count = (
    local.is_architecture_determination_required ||
    local.is_operating_system_determination_required ? 1 : 0
  )

  resource_id = local.virtual_machine_image_id
  type        = "Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/versions@2022-03-01"

  response_export_values = ["*"]
}
