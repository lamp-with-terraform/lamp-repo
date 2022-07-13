####ASG-vars#####
variable "key_name" {}

variable "public_key_path" {}

variable "region" {
  type = map
}
variable "route_table_cidr" {}

variable "web_ports" {
  type = list
}

variable "db_ports" {
  type = list
}

variable "db_private_subnet_cidr" {
  type = list
}

variable "vpc_cidr" {}

variable "public_subnet_cidr" {
  type = list
}

variable "app_private_subnet_cidr" {
  type = list
}

variable "env" {
  description = "env: dev or prod ?"
}
