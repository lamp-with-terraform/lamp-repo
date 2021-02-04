##############RDS##################

#create aws mysql rds instance
resource "aws_db_instance" "lamp_database_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  port                   = 3306
  vpc_security_group_ids = ["${var.my_db_security_group}"]
  db_subnet_group_name   = "${var.my_db_subnet_group_name}"
  name                   = "mydb"
  identifier             = "mysqldb"
  username               = "lampuser"
  password               = "lamppassword"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true

  tags = {
    Name = "lamp_database_instance"
  }
}
