variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "dns_servers" { type = list(string) default = [] }
variable "tags" { type = map(string) default = {} }
variable "enable_ddos" { type = bool default = false }
variable "ddos_plan_id" { type = string default = null }

variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })), [])
    nsg_name         = optional(string)
    route_table_name = optional(string)
  }))
  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet is required."
  }
}

variable "nsg_rules" {
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
  default = {}
}

variable "route_tables" {
  type = map(list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  })))
  default = {}
}

variable "private_dns_links" {
  type = map(object({
    zone_name    = string
    zone_rg_name = string
  }))
  default = {}
}
