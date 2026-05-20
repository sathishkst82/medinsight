variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key" { type = string }
variable "vm_definitions" {
  type = map(object({
    size              = string
    os_disk_type      = string
    enable_public_ip  = bool
    zone              = optional(string)
  }))
}
variable "tags" { type = map(string) default = {} }
