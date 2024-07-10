provider "azurerm" {
  features {}
}

variables {
  name                = "vm-example-dev-we-01"
  location            = "West Europe"
  resource_group_name = "rg-example-dev-we-01"

  image     = "Ubuntu2204"
  subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
}

run "test_input_image_urn_alias" {
  command = plan

  variables {
    image = "UnknownUrnAlias"
  }

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.image,
  ]
}

run "test_input_operating_system" {
  command = plan

  variables {
    image = "FailPublisher:FailOffer:FailSku:FailVersion"
  }

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.operating_system,
  ]
}

run "test_output_image" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }

  assert {
    condition = output.image == tomap({
      architecture = "x64"
      offer        = "WindowsServer"
      publisher    = "MicrosoftWindowsServer"
      sku          = "2022-datacenter-g2"
      urn          = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
      urnAlias     = "Win2022Datacenter"
      version      = "latest"
    })
    error_message = "Output image not equal to expected value"
  }
}
