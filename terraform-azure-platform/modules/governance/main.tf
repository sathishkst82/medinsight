locals { initiative_name = "Opella-Governance-Baseline" }
resource "azurerm_policy_set_definition" "baseline" {
  name         = "opella-governance-baseline"
  policy_type  = "Custom"
  display_name = local.initiative_name
  metadata     = jsonencode({ category = "Governance" })

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
    reference_id         = "require-tags"
    parameter_values     = jsonencode({ tagName = { value = "Owner" } })
  }
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    reference_id         = "allowed-locations"
    parameter_values     = jsonencode({ listOfAllowedLocations = { value = var.allowed_locations } })
  }
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25"
    reference_id         = "deny-public-ip"
  }
}
resource "azurerm_resource_group_policy_assignment" "baseline" {
  name                 = "opella-governance-baseline-assignment"
  resource_group_id    = var.scope
  policy_definition_id = azurerm_policy_set_definition.baseline.id
}
