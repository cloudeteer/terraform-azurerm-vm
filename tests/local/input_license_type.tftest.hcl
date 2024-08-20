mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  image = null
}

run "windows_image_should_match_license_type" {
  command = plan

  variables {
    image        = "Win2022Datacenter"
    license_type = "Windows_Server"
  }
}

run "windows_image_should_fail_with_linux_license_type" {
  command = plan

  variables {
    image        = "Win2022Datacenter"
    license_type = "RHEL_BASE"
  }

  expect_failures = [var.license_type]
}

run "linux_image_should_match_linzense_type" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "RHEL_BASE"
  }
}

run "linux_image_should_fail_with_windows_license_type" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "Windows_Server"
  }

  expect_failures = [var.license_type]
}

run "linux_image_should_fail_with_unknown_license_type" {
  command = plan

  variables {
    image        = "Ubuntu2204"
    license_type = "InvalidLicenseType"
  }

  expect_failures = [var.license_type]
}
