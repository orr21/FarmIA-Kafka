variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "mysql_admin" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}
