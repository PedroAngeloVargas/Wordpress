resource "aws_db_instance" "default" {
  allocated_storage      = 10
  identifier             = "database-1"
  db_name                = "banco"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.associacao_subnet_data.name
  vpc_security_group_ids = [aws_security_group.grupo_seguranca_rds.id]
  port                   = 3306

  tags = {
    Name = "MYSQL para o wordpress"
  }
}

resource "aws_db_subnet_group" "associacao_subnet_data" {
  name       = "meu-db-subnet-group"
  subnet_ids = [aws_subnet.minha_subnet_privada_data.id, aws_subnet.minha_subnet_privada_data_2.id]

  tags = {
    Name = "Associacao para o rds"
  }
}