# ─────────────────────────────────────────
# KEY PAIR
# ─────────────────────────────────────────

resource "aws_key_pair" "deployer" {
  key_name   = "proyecto-key"
  public_key = var.ssh_public_key
}

# ─────────────────────────────────────────
# AMI DINÁMICA
# ─────────────────────────────────────────

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─────────────────────────────────────────
# IAM ROLE (AWS Academy)
# ─────────────────────────────────────────

data "aws_iam_instance_profile" "lab_profile" {
  name = "LabInstanceProfile"
}

# ─────────────────────────────────────────
# EC2 - BACKEND VENTAS
# ─────────────────────────────────────────

resource "aws_instance" "back_ventas" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_1.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name
  depends_on                  = [aws_db_instance.mysql, aws_ecr_repository.back_ventas]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user_data.log 2>&1

    yum update -y
    yum install -y docker aws-cli
    systemctl start docker
    systemctl enable docker

    until docker info > /dev/null 2>&1; do
      echo "Esperando Docker..."
      sleep 5
    done

    # Login a ECR
    aws ecr get-login-password --region us-east-1 | \
      docker login --username AWS --password-stdin ${aws_ecr_repository.back_ventas.repository_url}

    # Pull y run
    docker pull ${aws_ecr_repository.back_ventas.repository_url}:latest

    docker run -d -p 8080:8080 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${random_password.db_password.result} \
      --restart always \
      --name ventas \
      ${aws_ecr_repository.back_ventas.repository_url}:latest

    echo "Backend ventas iniciado correctamente"
  EOF

  tags = { Name = "ec2-back-ventas" }
}

# ─────────────────────────────────────────
# EC2 - BACKEND DESPACHOS
# ─────────────────────────────────────────

resource "aws_instance" "back_despachos" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_2.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name
  depends_on                  = [aws_db_instance.mysql, aws_ecr_repository.back_despachos]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user_data.log 2>&1

    yum update -y
    yum install -y docker aws-cli
    systemctl start docker
    systemctl enable docker

    until docker info > /dev/null 2>&1; do
      echo "Esperando Docker..."
      sleep 5
    done

    # Login a ECR
    aws ecr get-login-password --region us-east-1 | \
      docker login --username AWS --password-stdin ${aws_ecr_repository.back_despachos.repository_url}

    # Pull y run
    docker pull ${aws_ecr_repository.back_despachos.repository_url}:latest

    docker run -d -p 8081:8081 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${random_password.db_password.result} \
      --restart always \
      --name despachos \
      ${aws_ecr_repository.back_despachos.repository_url}:latest

    echo "Backend despachos iniciado correctamente"
  EOF

  tags = { Name = "ec2-back-despachos" }
}
