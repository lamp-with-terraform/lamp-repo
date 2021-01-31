data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "lamp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#create EC2 instance
resource "aws_instance" "my_web_instance" {
ami = "${data.aws_ami.server_ami.id}"
instance_type = "t2.micro"
key_name = "${aws_key_pair.lamp_auth.id}" #make sure you have your_private_ket.pem file
vpc_security_group_ids = ["${var.web_security_group}"]
subnet_id = "${var.myvpc_public_subnet}"
tags = {
Name = "my_web_instance"
}
volume_tags = {
Name = "my_web_instance_volume"
}
provisioner "remote-exec" { #install apache, mysql client, php
inline = [
"sudo mkdir -p /var/www/html/",
"sudo yum update -y",
"sudo yum install -y httpd",
"sudo service httpd start",
"sudo service httpd enable",
"sudo usermod -a -G apache ec2-user",
"sudo chown -R ec2-user:apache /var/www",
"sudo yum install -y mysql php php-mysql"
]
}
provisioner "file" { #copy the index file form local to remote
source = "index.php"
destination = "/var/www/html/index.php"
}
connection {
type = "ssh"
user = "ec2-user"
password = ""
#copy <your_private_key>.pem to your local instance home directory
#restrict permission: chmod 400 <your_private_key>.pem
private_key = "${file("/home/ec2-user/.ssh/id_rsa")}"
}
}
