######################ELB##########################

# Creating application load balancer
resource "aws_lb" "lamp_lb" {
  name               = "lamplb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.my_web_security_group}"]
  subnets            = ["${var.my_public_subnet1}", "${var.my_public_subnet2}"]
}

# Configuring listener and target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.lamp_lb.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${var.my_tg_arn}"
  }
}
