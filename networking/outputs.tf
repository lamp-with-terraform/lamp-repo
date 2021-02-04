##############networking-outputs############
output "db_security_group" {
  value = "${aws_security_group.db_security_group.id}"
}

output "db_subnet_group_name" {
  value = "${aws_db_subnet_group.db_subnet_group.name}"
}

output "web_security_group" {
  value = "${aws_security_group.web_security_group.id}"
}

output "vpc_id" {
  value = "${aws_vpc.lamp_vpc.id}"
}

output "private_subnet1" {
  value = "${aws_subnet.lamp_vpc_app_private_subnet1.id}"
}

output "private_subnet2" {
  value = "${aws_subnet.lamp_vpc_app_private_subnet2.id}"
}

output "public_subnet1" {
  value = "${aws_subnet.lamp_vpc_public_subnet1.id}"
}

output "public_subnet2" {
  value = "${aws_subnet.lamp_vpc_public_subnet2.id}"
}
