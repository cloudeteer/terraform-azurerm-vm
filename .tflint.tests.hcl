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

  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
  version = "0.27.0"
}

rule "terraform_unused_required_providers" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}
