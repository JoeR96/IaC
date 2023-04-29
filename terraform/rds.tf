resource "aws_security_group" "rds" {
  name        = "rds_security_group"
  description = "RDS security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "rds_ingress" {
  security_group_id = aws_security_group.rds.id

  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

locals {
  rds_username = var.rds_username
  rds_password = var.rds_password
}

resource "aws_db_instance" "main" {
  allocated_storage     = 20
  instance_class        = "db.t2.micro"
  engine                = "mysql"
  engine_version        = "8.0.26"
  identifier            = "main-db-instance"
  name                  = "OperationStacked"
  username              = "devops69420"
  password              = "devops69420"
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible   = true
  availability_zone     = "eu-west-2a"
  skip_final_snapshot   = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  lifecycle {
    ignore_changes = [
      # Add any attributes here that you want to ignore when updating the infrastructure
      allocated_storage,
      engine_version,
      instance_class,
    ]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.secondary.id]

  tags = {
    Name = "main-db-subnet-group"
  }

   lifecycle {
    ignore_changes = [name] # Add other attributes to ignore if needed
  }
}
