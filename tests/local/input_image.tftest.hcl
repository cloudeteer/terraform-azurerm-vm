mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

mock_provider "azapi" {
  alias  = "linux"
  source = "tests/local/mocks"

  mock_data "azapi_resource" {
    defaults = {
      output = {
        properties = {
          architecture = "x64",
          osDiskImage = {
            operatingSystem = "Linux"
          }
        }
      }
    }
  }
}

variables {
  image = null
}

run "should_image_fail_on_unknown_urn_alias" {
  command = plan

  variables {
    image = "UnknownUrnAlias"
  }

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.image,
  ]
}

# TODO: The following tests should fail, but they cannot
# GitHub issue: https://github.com/cloudeteer/terraform-azurerm-vm/issues/3
# because we data sources which should fail the the unknown inputs are mocked by tests
// run "should_operating_system_fail_on_unknown_image_urn" {
//   command = plan

//   variables {
//     image = "UnkownPublisher:UnknownOffer:UnknownSku:latest"
//   }
// }

// run "test_input_operating_system_explicit_version" {
//   command = plan

//   variables {
//     image = "UnkownPublisher:UnknownOffer:UnknownSku:1.0.0"
//   }
// }

run "should_image_result_in_expected_output" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }

  assert {
    condition     = local.is_windows
    error_message = "Operating system does not match the expected value"
  }

  assert {
    condition = output.image == tomap({
      architecture     = "x64"
      offer            = "WindowsServer"
      operating_system = "Windows"
      publisher        = "MicrosoftWindowsServer"
      sku              = "2022-datacenter-g2"
      urn              = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
      urnAlias         = "Win2022Datacenter"
      version          = "latest"
    })
    error_message = "Output image not equal to expected value"
  }
}

run "operating_system_should_be_linux_with_urn_alias" {
  command = plan

  variables {
    image = "Ubuntu2204"
  }

  assert {
    condition     = local.is_linux
    error_message = "Operating system does not match the expected value"
  }
}

run "operating_system_should_be_linux_with_full_urn" {
  command = plan

  providers = {
    azapi   = azapi.linux
    azurerm = azurerm
    random  = random
    tls     = tls
  }

  variables {
    image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
  }

  assert {
    condition     = local.is_linux
    error_message = "Operating system does not match the expected value"
  }
}

run "operating_system_should_not_be_linux" {
  command = plan

  variables {
    image            = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
    operating_system = "Windows"
  }

  assert {
    condition     = !local.is_linux
    error_message = "Operating system does not match the expected value"
  }
}

run "operating_system_should_be_windows_with_urn_alias" {
  command = plan

  variables {
    image = "Win2022Datacenter"
  }

  assert {
    condition     = local.is_windows
    error_message = "Operating system does not match the expected value"
  }
}

run "operating_system_should_be_windows_with_full_urn" {
  command = plan

  variables {
    image = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
  }

  assert {
    condition     = local.is_windows
    error_message = "Operating system does not match the expected value"
  }
}

run "operating_system_should_not_be_windows" {
  command = plan

  variables {
    image            = "MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
    operating_system = "Linux"
  }

  assert {
    condition     = !local.is_windows
    error_message = "Operating system does not match the expected value"
  }
}
