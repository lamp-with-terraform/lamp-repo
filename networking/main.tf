#get AZ's details
data "aws_availability_zones" "availability_zones" {}
#create VPC
resource "aws_vpc" "myvpc" {
cidr_block = "${var.vpc_cidr}"
enable_dns_hostnames = true
tags {
Name = "myvpc"
}
}

#create public subnet
resource "aws_subnet" "myvpc_public_subnet" {
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "${var.subnet_one_cidr}"
availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
map_public_ip_on_launch = true
tags {
   Name = "myvpc_public_subnet"
  }
}
#create private subnet one
resource "aws_subnet" "myvpc_private_subnet_one" {
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "${element(var.subnet_two_cidr, 0)}"
availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
tags {
   Name = "myvpc_private_subnet_one"
  }
}
#create private subnet two
resource "aws_subnet" "myvpc_private_subnet_two" {
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "${element(var.subnet_two_cidr, 1)}"
availability_zone = "${data.aws_availability_zones.availability_zones.names[1]}"
tags {
   Name = "myvpc_private_subnet_two"
  }
}
#create internet gateway
resource "aws_internet_gateway" "myvpc_internet_gateway" {
vpc_id = "${aws_vpc.myvpc.id}"
tags {
Name = "myvpc_internet_gateway"
}
}
#create public route table (assosiated with internet gateway)
resource "aws_route_table" "myvpc_public_subnet_route_table" {
vpc_id = "${aws_vpc.myvpc.id}"
route {
cidr_block = "${var.route_table_cidr}"
gateway_id = "${aws_internet_gateway.myvpc_internet_gateway.id}"
}
tags {
Name = "myvpc_public_subnet_route_table"
}
}
#create private subnet route table
resource "aws_route_table" "myvpc_private_subnet_route_table" {
vpc_id = "${aws_vpc.myvpc.id}"
tags {
Name = "myvpc_private_subnet_route_table"
}
}
#create default route table
resource "aws_default_route_table" "myvpc_main_route_table" {
default_route_table_id = "${aws_vpc.myvpc.default_route_table_id}"
tags = {
Name = "myvpc_main_route_table"
}
}
#assosiate public subnet with public route table
resource "aws_route_table_association" "myvpc_public_subnet_route_table" {
subnet_id = "${aws_subnet.myvpc_public_subnet.id}"
route_table_id = "${aws_route_table.myvpc_public_subnet_route_table.id}"
}
#assosiate private subnets with private route table
resource "aws_route_table_association" "myvpc_private_subnet_one_route_table_assosiation" {
subnet_id = "${aws_subnet.myvpc_private_subnet_one.id}"
route_table_id = "${aws_route_table.myvpc_private_subnet_route_table.id}"
}
resource "aws_route_table_association" "myvpc_private_subnet_two_route_table_assosiation" {
subnet_id = "${aws_subnet.myvpc_private_subnet_two.id}"
route_table_id = "${aws_route_table.myvpc_private_subnet_route_table.id}"
}
#create security group for web
resource "aws_security_group" "web_security_group" {
name = "web_security_group"
description = "Allow all inbound traffic"
vpc_id = "${aws_vpc.myvpc.id}"
tags {
Name = "myvpc_web_security_group"
}
}
#create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
count = "${length(var.web_ports)}"
type = "ingress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.web_ports, count.index)}"
to_port = "${element(var.web_ports, count.index)}"
security_group_id = "${aws_security_group.web_security_group.id}"
}
#create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
count = "${length(var.web_ports)}"
type = "egress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.web_ports, count.index)}"
to_port = "${element(var.web_ports, count.index)}"
security_group_id = "${aws_security_group.web_security_group.id}"
}
#create security group for db
resource "aws_security_group" "db_security_group" {
name = "db_security_group"
description = "Allow all inbound traffic"
vpc_id = "${aws_vpc.myvpc.id}"
tags {
Name = "myvpc_db_security_group"
}
}
#create security group ingress rule for db
resource "aws_security_group_rule" "db_ingress" {
count = "${length(var.db_ports)}"
type = "ingress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.db_ports, count.index)}"
to_port = "${element(var.db_ports, count.index)}"
security_group_id = "${aws_security_group.db_security_group.id}"
}
#create security group egress rule for db
resource "aws_security_group_rule" "db_egress" {
count = "${length(var.db_ports)}"
type = "egress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.db_ports, count.index)}"
to_port = "${element(var.db_ports, count.index)}"
security_group_id = "${aws_security_group.db_security_group.id}"
}

#create aws rds subnet groups
resource "aws_db_subnet_group" "my_database_subnet_group" {
name = "mydbsg"
subnet_ids = ["${aws_subnet.myvpc_private_subnet_one.id}", "${aws_subnet.myvpc_private_subnet_two.id}"]
tags = {
Name = "my_database_subnet_group"
}
}

