mock_provider "azapi" { source = "tests/local/mocks" }
mock_provider "azurerm" { source = "tests/local/mocks" }
mock_provider "random" { source = "tests/local/mocks" }
mock_provider "tls" { source = "tests/local/mocks" }

variables {
  # Unset default, set in variables.auto.tfvars
  image = true
}

run "hotpatching_and_bypass_platform_security_checks_disabled_should_succeed_on_windows" {
  command = plan

  variables {
    image                                                  = "Win2022Datacenter"
    hotpatching_enabled                                    = false
    bypass_platform_safety_checks_on_user_schedule_enabled = false
  }
}

run "hotpatching_enabled_and_bypass_platform_security_checks_disabled_should_succeed_on_windows" {
  command = plan

  variables {
    image                                                  = "Win2022Datacenter"
    hotpatching_enabled                                    = true
    bypass_platform_safety_checks_on_user_schedule_enabled = false
  }
}

run "hotpatching_disabled_and_bypass_platform_security_checks_enabled_should_succeed_on_windows" {
  command = plan

  variables {
    image                                                  = "Win2022Datacenter"
    hotpatching_enabled                                    = false
    bypass_platform_safety_checks_on_user_schedule_enabled = true
  }
}

run "hotpatching_and_bypass_platform_security_checks_enabled_should_fail_on_windows" {
  command = plan

  variables {
    image                                                  = "Win2022Datacenter"
    hotpatching_enabled                                    = true
    bypass_platform_safety_checks_on_user_schedule_enabled = true
  }

  expect_failures = [var.hotpatching_enabled]
}


run "hotpatching_and_bypass_platform_security_checks_disabled_should_succeed_on_linux" {
  command = plan

  variables {
    image                                                  = "Ubuntu2204"
    hotpatching_enabled                                    = false
    bypass_platform_safety_checks_on_user_schedule_enabled = false
  }
}

run "hotpatching_enabled_and_bypass_platform_security_checks_disabled_should_fail_on_linux" {
  command = plan

  variables {
    image                                                  = "Ubuntu2204"
    hotpatching_enabled                                    = true
    bypass_platform_safety_checks_on_user_schedule_enabled = false
  }

  expect_failures = [var.hotpatching_enabled]
}

run "hotpatching_disabled_and_bypass_platform_security_checks_enabled_should_succeed_on_linux" {
  command = plan

  variables {
    image                                                  = "Ubuntu2204"
    hotpatching_enabled                                    = false
    bypass_platform_safety_checks_on_user_schedule_enabled = true
  }
}

run "hotpatching_and_bypass_platform_security_checks_enabled_should_fail_on_linux" {
  command = plan

  variables {
    image                                                  = "Ubuntu2204"
    hotpatching_enabled                                    = true
    bypass_platform_safety_checks_on_user_schedule_enabled = true
  }

  expect_failures = [var.hotpatching_enabled]
}
