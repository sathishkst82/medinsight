variable "admin_username" { type = string default = "azureuser" }
variable "ssh_public_key" { type = string }
variable "extra_tags" { type = map(string) default = {} }
