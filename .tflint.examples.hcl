tflint {
  required_version = "~> 0.50"
}

plugin "terraform" {
  enabled = true

  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.12.0"

  preset = "all"
}

plugin "azurerm" {
  enabled = true

  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
  version = "0.28.0"
}

rule "terraform_documented_variables" {
  enabled = false
}

rule "terraform_documented_outputs" {
  enabled = false
}

rule "terraform_module_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}

rule "terraform_unused_required_providers" {
  enabled = false
}
