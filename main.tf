provider "aws" {
  region = "${var.region}"
}

# Deploy Networking Resources
module "networking" {
  source       = "./networking"
}

# Deploy Compute Resources
module "compute" {
  source          = "./compute"
  key_name        = "${var.key_name}"
  public_key_path = "${var.public_key_path}"
  myvpc_public_subnet        = "${module.networking.myvpc_public_subnet}"
  web_security_group  = "${module.networking.web_security_group}"
}

module "rds" {
  source          = "./rds"
  my_database_subnet_group = "${module.networking.my_database_subnet_group}"
  db_security_group = "${module.networking.db_security_group}"
  
}
