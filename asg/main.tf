################ASG#################

# Getting id of ami
data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

#Creating key pair
resource "aws_key_pair" "lamp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#Creating lunch configuration
resource "aws_launch_configuration" "lamp_conf" {
  name          = "lampconf"
  image_id      = "${data.aws_ami.server_ami.id}"
  instance_type = "t2.micro"

  user_data = <<EOF
#!/bin/bash
sudo mkdir -p /var/www/html/
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
sudo chkconfig httpd on
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo yum install -y mysql php php-mysql
sudo yum install git -y
git clone https://github.com/lamp-with-terraform/index.git
mv index/index.php /var/www/html/index.php
cd /var/www/html
sed -i 's/enter_the_name/${var.my_db_server_address}/' index.php
mysql -h "${var.my_db_server_address}" -P 3306 -u lampuser -plamppassword
USE mydb;
CREATE TABLE counter (visits int(10) NOT NULL);
INSERT INTO counter(visits) values(1);
exit
EOF

  security_groups = ["${var.my_web_security_group}"]
  key_name        = "${aws_key_pair.lamp_auth.id}"

  // If the launch_configuration is modified:
  // --> Create New resources before destroying the old resources
  lifecycle {
    create_before_destroy = true
  }
}

#Creating target group
resource "aws_lb_target_group" "lamp_tg" {
  name     = "LampTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.my_vpc_id}"
}

# Creating auto scaling group
resource "aws_autoscaling_group" "lamp_asg" {
  name                      = "LampASG"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.lamp_conf.name}"
  vpc_zone_identifier       = ["${var.my_private_subnet1}", "${var.my_private_subnet2}"]
  target_group_arns         = ["${aws_lb_target_group.lamp_tg.arn}"]

  # availability_zones = ["us-east-1a"]
  # placement_group           = aws_placement_group.test.id
  tag {
    key                 = "name"
    value               = "Lamp-ASG"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}
