mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  image = null
}

run "test_input_license_type_windows" {
  command = plan

  variables {
    image        = "Win2022Datacenter"
    license_type = "Windows_Server"
  }
}

run "test_input_license_type_windows_fail_on_linux_license_type" {
  command = plan

  variables {
    image        = "Win2022Datacenter"
    license_type = "RHEL_BASE"
  }

  expect_failures = [var.license_type]
}

run "test_input_license_type_linux" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "RHEL_BASE"
  }
}

run "test_input_license_type_linux_fail_on_windows_license_type" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "Windows_Server"
  }

  expect_failures = [var.license_type]
}

run "test_input_license_type_invalid_license_type" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "InvalidLicenseType"
  }

  expect_failures = [var.license_type]
}
