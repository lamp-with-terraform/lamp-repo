# Setting up region
provider "aws" {
  region = "${lookup(var.region, var.env)}"
}

#remote tfstate
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-bucket-0123456789"
    key    = "/home/ec2-user/environment/lamp-repo/terraform.tfstate"
    region = "us-east-1"
  }
}

# Deploy Networking Resources

module "networking" {
  source                  = "./networking"
  route_table_cidr        = "${var.route_table_cidr}"
  web_ports               = "${var.web_ports}"
  app_private_subnet_cidr = "${var.app_private_subnet_cidr}"
  db_private_subnet_cidr  = "${var.db_private_subnet_cidr}"
  vpc_cidr                = "${var.vpc_cidr}"
  db_ports                = "${var.db_ports}"
  public_subnet_cidr      = "${var.public_subnet_cidr}"
}

# Deploy RDS
module "rds" {
  source                  = "./rds"
  my_db_subnet_group_name = "${module.networking.db_subnet_group_name}"
  my_db_security_group    = "${module.networking.db_security_group}"
}

# Deploy ASG
module "asg" {
  source                = "./asg"
  key_name              = "${var.key_name}"
  public_key_path       = "${var.public_key_path}"
  my_web_security_group = "${module.networking.web_security_group}"
  my_vpc_id             = "${module.networking.vpc_id}"
  my_private_subnet1    = "${module.networking.private_subnet1}"
  my_private_subnet2    = "${module.networking.private_subnet2}"
  my_db_server_address  = "${module.rds.db_server_address}"
}

# Deploy ELB
module "elb" {
  source                = "./elb"
  my_web_security_group = "${module.networking.web_security_group}"
  my_public_subnet1     = "${module.networking.public_subnet1}"
  my_public_subnet2     = "${module.networking.public_subnet2}"
  my_tg_arn             = "${module.asg.tg_arn}"
}
