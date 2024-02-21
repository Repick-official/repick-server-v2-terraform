resource "aws_db_subnet_group" "repick-db-subnet-group" {
  name       = "repick-db-subnet-group"
  subnet_ids = [aws_subnet.repick-vpc-private-subnet-1.id, aws_subnet.repick-vpc-private-subnet-2.id]

  tags = {
    Name = "repick-db-subnet-group"
  }
}

resource "aws_db_instance" "repick-mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.repick-db-subnet-group.name
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.repick-sg.id]

  tags = {
    Name = "repick-mysql"
  }
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS"
  value       = aws_db_instance.repick-mysql.endpoint
}