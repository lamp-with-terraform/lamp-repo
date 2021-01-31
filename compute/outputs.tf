#output webserver address
output "web_server_address" {
value = "${aws_instance.my_web_instance.public_dns}"
}
