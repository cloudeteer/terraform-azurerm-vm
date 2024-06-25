variables {
  example_variable = "example value"
}

run "test_input_validation" {
  command = plan

  variables {
    example_variable = "ex"
  }

  # https://developer.hashicorp.com/terraform/language/tests#expecting-failures
  expect_failures = [
    var.example_variable,
  ]
}

run "test_output" {
  command = plan

  assert {
    condition     = output.example_output == "example value"
    error_message = "Output example_output not equal to expected value"
  }
}
