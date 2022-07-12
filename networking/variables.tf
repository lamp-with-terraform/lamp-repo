###################Network_var###############

variable "vpc_cidr" {}

variable "public_subnet_cidr" {
  type = list
}

variable "app_private_subnet_cidr" {
  type = list
}

variable "db_private_subnet_cidr" {
  type = list
}

variable "route_table_cidr" {}

variable "db_ports" {
  type = list
}

variable "web_ports" {
  type = list
}
