resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos && var.ddos_plan_id != null ? [1] : []
    content {
      id     = var.ddos_plan_id
      enable = true
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastReviewed"]]
  }
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_group" "this" {
  for_each            = { for k, v in var.subnets : k => v if try(v.nsg_name, null) != null }
  name                = each.value.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = merge([
    for subnet_name, rules in var.nsg_rules : {
      for r in rules : "${subnet_name}-${r.name}" => merge(r, { subnet_name = subnet_name })
    }
  ]...)

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_name].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = azurerm_network_security_group.this
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.id
}

resource "azurerm_route_table" "this" {
  for_each            = var.route_tables
  name                = "rt-${var.vnet_name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "route" {
    for_each = each.value
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = azurerm_route_table.this
  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_links
  name                  = "link-${var.vnet_name}-${each.key}"
  resource_group_name   = each.value.zone_rg_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
}
