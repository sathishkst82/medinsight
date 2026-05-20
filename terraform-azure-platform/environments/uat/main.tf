locals {
  project     = "opella"
  location    = "eastus"
  env         = terraform.workspace != "default" ? terraform.workspace : basename(path.cwd)
  region_code = "eus"

  names = {
    rg      = "rg-${local.project}-${local.env}-${local.location}"
    vnet    = "vnet-${local.project}-${local.env}-${local.location}"
    vm      = "vm-${local.project}-${local.env}-${local.location}-001"
    storage = "st${local.project}${local.env}${local.region_code}001"
  }

  cidr_map = {
    dev  = "10.10.0.0/16"
    uat  = "10.15.0.0/16"
    prod = "10.20.0.0/16"
  }

  common_tags = merge({
    Environment = upper(local.env)
    Project     = local.project
    ManagedBy   = "Terraform"
    Owner       = "platform-team"
    CostCenter  = "CC-1001"
    Region      = local.location
    Application = "devops-orchestrator"
  }, var.extra_tags)

  subnets = {
    management-subnet      = { address_prefixes = [cidrsubnet(local.cidr_map[local.env], 8, 1)], nsg_name = "nsg-mgmt-${local.env}" }
    application-subnet     = { address_prefixes = [cidrsubnet(local.cidr_map[local.env], 8, 2)], nsg_name = "nsg-app-${local.env}" }
    data-subnet            = { address_prefixes = [cidrsubnet(local.cidr_map[local.env], 8, 3)], nsg_name = "nsg-data-${local.env}" }
    private-endpoint-subnet = { address_prefixes = [cidrsubnet(local.cidr_map[local.env], 8, 4)] }
    future-reserved-subnet = { address_prefixes = [cidrsubnet(local.cidr_map[local.env], 8, 15)] }
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.names.rg
  location = local.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_name           = local.names.vnet
  address_space       = [local.cidr_map[local.env]]
  subnets             = local.subnets
  nsg_rules = {
    "management-subnet" = [{ name = "allow-ssh", priority = 100, direction = "Inbound", access = "Allow", protocol = "Tcp", source_port_range = "*", destination_port_range = "22", source_address_prefix = "10.0.0.0/8", destination_address_prefix = "*" }]
  }
  tags = local.common_tags
}

module "vm" {
  source              = "../../modules/vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = module.vnet.subnet_ids["management-subnet"]
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  vm_definitions      = { (local.names.vm) = { size = "Standard_B2ms", os_disk_type = "StandardSSD_LRS", enable_public_ip = local.env != "prod" } }
  tags                = local.common_tags
}

module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  storage_account_name = local.names.storage
  containers           = ["tfstate", "artifacts", "logs"]
  tags                 = local.common_tags
}

module "governance" {
  source            = "../../modules/governance"
  scope             = azurerm_resource_group.this.id
  allowed_locations = [local.location]
  required_tags     = ["Environment", "Owner", "CostCenter"]
}
