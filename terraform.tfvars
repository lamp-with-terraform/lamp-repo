key_name = "lamp_key"
public_key_path = "/home/armeng/.ssh/id_rsa.pub"
region = {
    dev = "eu-west-2"
    prod = "us-east-2"
}
vpc_cidr = "10.99.0.0/16"
public_subnet_cidr = ["10.99.1.0/24","10.99.2.0/24"]
app_private_subnet_cidr = ["10.99.11.0/24","10.99.12.0/24"]
db_private_subnet_cidr = ["10.99.21.0/24","10.99.22.0/24"]
route_table_cidr = "0.0.0.0/0"
web_ports = ["22","80", "443", "3306"]
db_ports = ["22", "3306"]
