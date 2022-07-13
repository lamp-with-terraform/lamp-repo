#getting load balancer dns
output "public_dns" {
  value = "${module.elb.lb_dns}"
}
