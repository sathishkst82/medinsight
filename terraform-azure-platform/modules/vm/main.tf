resource "azurerm_public_ip" "this" {
  for_each            = { for k, v in var.vm_definitions : k => v if v.enable_public_ip }
  name                = "pip-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
resource "azurerm_network_interface" "this" {
  for_each            = var.vm_definitions
  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.this[each.key].id, null)
  }
  tags = var.tags
}
resource "azurerm_linux_virtual_machine" "this" {
  for_each                        = var.vm_definitions
  name                            = each.key
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  zone                            = try(each.value.zone, null)
  network_interface_ids           = [azurerm_network_interface.this[each.key].id]
  identity { type = "SystemAssigned" }
  admin_ssh_key { username = var.admin_username public_key = var.ssh_public_key }
  os_disk { caching = "ReadWrite" storage_account_type = each.value.os_disk_type }
  source_image_reference { publisher = "Canonical" offer = "0001-com-ubuntu-server-jammy" sku = "22_04-lts" version = "latest" }
  boot_diagnostics {}
  lifecycle { ignore_changes = [tags["PatchWindow"]] }
  tags = var.tags
}
