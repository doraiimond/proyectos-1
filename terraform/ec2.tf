# ─────────────────────────────────────────
<<<<<<< HEAD
# KEY PAIR
=======
# KEY PAIR (para SSH a las EC2)
>>>>>>> parent of fa3219c (ksajdkajsdksa)
# ─────────────────────────────────────────
resource "aws_key_pair" "deployer" {
  key_name   = "proyecto-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

# ─────────────────────────────────────────
<<<<<<< HEAD
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
=======
# EC2 - BACKEND VENTAS (puerto 8080)
# ─────────────────────────────────────────
resource "aws_instance" "back_ventas" {
  ami                         = "ami-0c02fb55956c7d316"
>>>>>>> parent of fa3219c (ksajdkajsdksa)
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_1.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
<<<<<<< HEAD
  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name
  depends_on                  = [aws_db_instance.mysql, aws_ecr_repository.back_ventas]
=======
>>>>>>> parent of fa3219c (ksajdkajsdksa)

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker aws-cli
    systemctl start docker
    systemctl enable docker

<<<<<<< HEAD
    until docker info > /dev/null 2>&1; do
      echo "Esperando Docker..."
      sleep 5
    done

    # Login a ECR
    aws ecr get-login-password --region us-east-1 | \
      docker login --username AWS --password-stdin ${aws_ecr_repository.back_ventas.repository_url}

    # Pull y run
    docker pull ${aws_ecr_repository.back_ventas.repository_url}:latest

=======
    sleep 90

    cd /home/ec2-user
    git clone https://github.com/doraiimond/proyectos-1.git proyecto
    cd proyecto/proyecto-semestral/back-Ventas_SpringBoot/Springboot-API-REST

    docker build -t back-ventas .

>>>>>>> parent of fa3219c (ksajdkajsdksa)
    docker run -d -p 8080:8080 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${var.db_password} \
      --restart always \
      --name ventas \
<<<<<<< HEAD
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
=======
      back-ventas
  EOF

  tags = { Name = "ec2-back-ventas" }
  depends_on = [aws_db_instance.mysql]
}

# ─────────────────────────────────────────
# EC2 - BACKEND DESPACHOS (puerto 8081)
# ─────────────────────────────────────────
resource "aws_instance" "back_despachos" {
  ami                         = "ami-0c02fb55956c7d316"
>>>>>>> parent of fa3219c (ksajdkajsdksa)
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_2.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
<<<<<<< HEAD
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
=======

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    sleep 90

    cd /home/ec2-user
    git clone https://github.com/doraiimond/proyectos-1.git proyecto
    cd proyecto/proyecto-semestral/back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO

    docker build -t back-despachos .
>>>>>>> parent of fa3219c (ksajdkajsdksa)

    docker run -d -p 8081:8081 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
<<<<<<< HEAD
      -e DB_PASSWORD=${random_password.db_password.result} \
      --restart always \
      --name despachos \
      ${aws_ecr_repository.back_despachos.repository_url}:latest

    echo "Backend despachos iniciado correctamente"
  EOF

  tags = { Name = "ec2-back-despachos" }
=======
      -e DB_PASSWORD=${var.db_password} \
      --restart always \
      --name despachos \
      back-despachos
  EOF

  tags = { Name = "ec2-back-despachos" }
  depends_on = [aws_db_instance.mysql]
>>>>>>> parent of fa3219c (ksajdkajsdksa)
}
