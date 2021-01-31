#output webserver and dbserver address
output "db_server_address" {
value = "${aws_db_instance.my_database_instance.address}"
}
