#output webserver and dbserver address
output "db_server_address" {
  value = "${aws_db_instance.lamp_database_instance.address}"
}
