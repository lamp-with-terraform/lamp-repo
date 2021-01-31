variable "key_name" {}
variable "public_key_path" {}
variable "region" {}
variable "vpc_cidr" {}
variable "subnet_one_cidr" {}
variable "subnet_two_cidr" {
    type = "list"
}
variable "route_table_cidr" {}
variable "web_ports" {
    type = "list"
}
variable "db_ports" {
    type = "list"
}


