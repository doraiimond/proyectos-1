# ─────────────────────────────────────────
# RDS MYSQL
# ─────────────────────────────────────────

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"  # excluye caracteres que rompen MySQL o bash
}


resource "aws_db_subnet_group" "main" {
  name       = "proyecto-db-subnet-group"
  subnet_ids = [aws_subnet.privada_1.id, aws_subnet.privada_2.id]
  tags       = { Name = "proyecto-db-subnet-group" }
}

resource "aws_db_instance" "mysql" {
  identifier             = "proyecto-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags                   = { Name = "rds-mysql" }
}
