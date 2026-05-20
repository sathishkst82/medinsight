resource "azurerm_storage_account" "this" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = false
  tags                            = var.tags
}
resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id
  rule {
    name    = "default-lifecycle"
    enabled = true
    filters { blob_types = ["blockBlob"] prefix_match = ["logs/"] }
    actions { base_blob { delete_after_days_since_modification_greater_than = 90 } }
  }
}
