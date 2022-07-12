################NETWORK##################

#get AZ's details
data "aws_availability_zones" "availability_zones" {}

#create VPC
resource "aws_vpc" "lamp_vpc" {
  cidr_block = "${var.vpc_cidr}"

  #enable_dns_hostnames = true
  tags = {
    Name = "lamp-vpc"
  }
}

#create public subnet1
resource "aws_subnet" "lamp_vpc_public_subnet1" {
  vpc_id                  = "${aws_vpc.lamp_vpc.id}"
  cidr_block              = "${element(var.public_subnet_cidr, 0)}"
  availability_zone       = "${data.aws_availability_zones.availability_zones.names[0]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "lamp-vpc-public-subnet1"
  }
}

#create public subnet2
resource "aws_subnet" "lamp_vpc_public_subnet2" {
  vpc_id                  = "${aws_vpc.lamp_vpc.id}"
  cidr_block              = "${element(var.public_subnet_cidr, 1)}"
  availability_zone       = "${data.aws_availability_zones.availability_zones.names[1]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "lamp-vpc-public-subnet2"
  }
}

#create private subnet for app 1
resource "aws_subnet" "lamp_vpc_app_private_subnet1" {
  vpc_id            = "${aws_vpc.lamp_vpc.id}"
  cidr_block        = "${element(var.app_private_subnet_cidr, 0)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"

  tags = {
    Name = "app-private_subnet1"
  }
}

#create private subnet for app 2
resource "aws_subnet" "lamp_vpc_app_private_subnet2" {
  vpc_id            = "${aws_vpc.lamp_vpc.id}"
  cidr_block        = "${element(var.app_private_subnet_cidr, 1)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[1]}"

  tags = {
    Name = "app-private_subnet2"
  }
}

#create private subnet for db 1
resource "aws_subnet" "lamp_vpc_db_private_subnet1" {
  vpc_id            = "${aws_vpc.lamp_vpc.id}"
  cidr_block        = "${element(var.db_private_subnet_cidr, 0)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"

  tags = {
    Name = "db-private-subnet1"
  }
}

#create private subnet for db 2
resource "aws_subnet" "lamp_vpc_db_private_subnet2" {
  vpc_id            = "${aws_vpc.lamp_vpc.id}"
  cidr_block        = "${element(var.db_private_subnet_cidr, 1)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[1]}"

  tags = {
    Name = "db-private-subnet2"
  }
}

#create internet gateway
resource "aws_internet_gateway" "lamp_internet_gateway" {
  vpc_id = "${aws_vpc.lamp_vpc.id}"

  tags = {
    Name = "lamp-internet-gateway"
  }
}

#create public route table (assosiated with internet gateway)
resource "aws_route_table" "lamp_public_subnet_route_table" {
  vpc_id = "${aws_vpc.lamp_vpc.id}"

  route {
    cidr_block = "${var.route_table_cidr}"
    gateway_id = "${aws_internet_gateway.lamp_internet_gateway.id}"
  }

  tags = {
    Name = "lamp-public-subnet-route-table"
  }
}

#create private subnet route table
resource "aws_route_table" "lamp_private_subnet_route_table" {
  vpc_id = "${aws_vpc.lamp_vpc.id}"

  route {
    cidr_block     = "${var.route_table_cidr}"
    nat_gateway_id = "${aws_nat_gateway.lamp_ngw.id}"
  }

  tags = {
    Name = "lamp-private-subnet-route-table"
  }
}

#create default route table
resource "aws_default_route_table" "lamp_main_route_table" {
  default_route_table_id = "${aws_vpc.lamp_vpc.default_route_table_id}"

  tags = {
    Name = "lamp-main-route-table"
  }
}

#assosiate public subnets with public route table
resource "aws_route_table_association" "lamp_public_subnet1_route_association" {
  subnet_id      = "${aws_subnet.lamp_vpc_public_subnet1.id}"
  route_table_id = "${aws_route_table.lamp_public_subnet_route_table.id}"
}

resource "aws_route_table_association" "lamp_public_subnet2_route_association" {
  subnet_id      = "${aws_subnet.lamp_vpc_public_subnet2.id}"
  route_table_id = "${aws_route_table.lamp_public_subnet_route_table.id}"
}

#assosiate private subnets with private route table
resource "aws_route_table_association" "lamp_app_private_subnet1_route_table_assosiation" {
  subnet_id      = "${aws_subnet.lamp_vpc_app_private_subnet1.id}"
  route_table_id = "${aws_route_table.lamp_private_subnet_route_table.id}"
}

resource "aws_route_table_association" "lamp_app_private_subnet2_route_table_assosiation" {
  subnet_id      = "${aws_subnet.lamp_vpc_app_private_subnet2.id}"
  route_table_id = "${aws_route_table.lamp_private_subnet_route_table.id}"
}

resource "aws_route_table_association" "lamp_db_private_subnet1_route_table_assosiation" {
  subnet_id      = "${aws_subnet.lamp_vpc_db_private_subnet1.id}"
  route_table_id = "${aws_route_table.lamp_private_subnet_route_table.id}"
}

resource "aws_route_table_association" "lamp_db_private_subnet2_route_table_assosiation" {
  subnet_id      = "${aws_subnet.lamp_vpc_db_private_subnet2.id}"
  route_table_id = "${aws_route_table.lamp_private_subnet_route_table.id}"
}

#creating elastic IP
resource "aws_eip" "nat_eip" {
  vpc = true
}

#Creating Nat Gateway
resource "aws_nat_gateway" "lamp_ngw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.lamp_vpc_public_subnet1.id}"

  tags = {
    Name = "Lamp-NAT-Gateway"
  }
}

#create security group for web
resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.lamp_vpc.id}"

  tags {
    Name = "lamp-vpc-web-security-group"
  }
}

#create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
  count             = "${length(var.web_ports)}"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${var.route_table_cidr}"]
  from_port         = "${element(var.web_ports, count.index)}"
  to_port           = "${element(var.web_ports, count.index)}"
  security_group_id = "${aws_security_group.web_security_group.id}"
}

#create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
  count             = "${length(var.web_ports)}"
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.web_ports, count.index)}"
  to_port           = "${element(var.web_ports, count.index)}"
  security_group_id = "${aws_security_group.web_security_group.id}"
}

#create security group for db
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.lamp_vpc.id}"

  tags = {
    Name = "lamp-vp-db-security-group"
  }
}

#create security group ingress rule for db
resource "aws_security_group_rule" "db_ingress" {
  count             = "${length(var.db_ports)}"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${var.vpc_cidr}"]
  from_port         = "${element(var.db_ports, count.index)}"
  to_port           = "${element(var.db_ports, count.index)}"
  security_group_id = "${aws_security_group.db_security_group.id}"
}

#create security group egress rule for db
resource "aws_security_group_rule" "db_egress" {
  count             = "${length(var.db_ports)}"
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.db_ports, count.index)}"
  to_port           = "${element(var.db_ports, count.index)}"
  security_group_id = "${aws_security_group.db_security_group.id}"
}

#create db subnet groups
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "dbsg"
  subnet_ids = ["${aws_subnet.lamp_vpc_db_private_subnet1.id}", "${aws_subnet.lamp_vpc_db_private_subnet2.id}"]

  tags = {
    Name = "db-subnet-group"
  }
}
