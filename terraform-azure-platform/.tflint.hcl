plugin "azurerm" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

config {
  format = "compact"
}

rule "terraform_required_providers" { enabled = true }
rule "terraform_required_version" { enabled = true }
rule "azurerm_resource_missing_tags" { enabled = true }
rule "azurerm_virtual_network_invalid_address_space" { enabled = true }
