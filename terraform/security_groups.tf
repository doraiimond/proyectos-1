# ─────────────────────────────────────────
# SG - ALB (acepta tráfico HTTP desde internet)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_alb" {
<<<<<<< HEAD
  name        = "proyecto-alb-sg"
  description = "ALB: acepta trafico HTTP publico"
  vpc_id      = aws_vpc.main.id
=======
  name   = "proyecto-alb-sg"
  vpc_id = aws_vpc.main.id
>>>>>>> parent of fa3219c (ksajdkajsdksa)

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
<<<<<<< HEAD

  tags = { Name = "proyecto-alb-sg" }
=======
  tags = { Name = "sg-alb" }
>>>>>>> parent of fa3219c (ksajdkajsdksa)
}

# ─────────────────────────────────────────
# SG - EC2 backends (acepta tráfico desde ALB y SSH)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_backend" {
<<<<<<< HEAD
  name        = "proyecto-backend-sg"
  description = "EC2 backends: 8080, 8081 desde ALB; SSH desde internet"
  vpc_id      = aws_vpc.main.id
=======
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


>>>>>>> parent of fa3219c (ksajdkajsdksa)

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
<<<<<<< HEAD

  tags = { Name = "proyecto-backend-sg" }
=======
  tags = { Name = "sg-backend" }
>>>>>>> parent of fa3219c (ksajdkajsdksa)
}

# ─────────────────────────────────────────
# SG - RDS (acepta tráfico solo desde backends)
# ─────────────────────────────────────────
resource "aws_security_group" "sg_rds" {
<<<<<<< HEAD
  name        = "proyecto-rds-sg"
  description = "RDS MySQL: solo desde las EC2"
  vpc_id      = aws_vpc.main.id
=======
  name   = "proyecto-rds-sg"
  vpc_id = aws_vpc.main.id
>>>>>>> parent of fa3219c (ksajdkajsdksa)

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
<<<<<<< HEAD

  tags = { Name = "proyecto-rds-sg" }
=======
  tags = { Name = "sg-rds" }
>>>>>>> parent of fa3219c (ksajdkajsdksa)
}
