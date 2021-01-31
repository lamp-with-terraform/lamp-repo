#-----networking/outputs.tf

output "myvpc_public_subnet" {
  value = "${aws_subnet.myvpc_public_subnet.id}"
}

output "web_security_group" {
  value = "${aws_security_group.web_security_group.id}"
}

output "db_security_group" {
  value = "${aws_security_group.db_security_group.id}"
}

output "my_database_subnet_group" {
  value = "${aws_db_subnet_group.my_database_subnet_group.id}"
}
