package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestVnetOutputs(t *testing.T) {
  opts := &terraform.Options{TerraformDir: "../../environments/dev", Vars: map[string]interface{}{"ssh_public_key": "ssh-rsa AAAATEST"}}
  terraform.InitAndPlan(t, opts)
  vnetID := terraform.Output(t, opts, "vnet_id")
  rg := terraform.Output(t, opts, "resource_group_name")
  assert.Contains(t, vnetID, "/virtualNetworks/")
  assert.Contains(t, rg, "rg-opella-dev")
}
