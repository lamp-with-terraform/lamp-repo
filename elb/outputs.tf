output "lb_dns" {
  value = "${aws_lb.lamp_lb.dns_name}"
}
