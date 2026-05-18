# ─────────────────────────────────────────
# SG - ALB (acepta tráfico HTTP desde internet)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_alb" {
  name   = "proyecto-alb-sg"
  vpc_id = aws_vpc.main.id

ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port   = 8081
  to_port     = 8081
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-alb" }
}

# ─────────────────────────────────────────
# SG - EC2 backends (acepta tráfico desde ALB y SSH)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_backend" {
  name   = "proyecto-backend-sg"
  vpc_id = aws_vpc.main.id

ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  from_port   = 8081
  to_port     = 8081
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}



  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-backend" }
}

# ─────────────────────────────────────────
# SG - RDS (acepta tráfico solo desde backends)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_rds" {
  name   = "proyecto-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_backend.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-rds" }
}
