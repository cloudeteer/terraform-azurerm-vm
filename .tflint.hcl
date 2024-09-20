tflint {
  required_version = "~> 0.50"
}

plugin "terraform" {
  enabled = true

  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.9.1"

  preset = "all"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
