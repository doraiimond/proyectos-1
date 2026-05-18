# ─────────────────────────────────────────
# KEY PAIR (para SSH a las EC2)
# ─────────────────────────────────────────
resource "aws_key_pair" "deployer" {
  key_name   = "proyecto-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

# ─────────────────────────────────────────
# EC2 - BACKEND VENTAS (puerto 8080)
# ─────────────────────────────────────────
resource "aws_instance" "back_ventas" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_1.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

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
    cd proyecto/proyecto-semestral/back-Ventas_SpringBoot/Springboot-API-REST

    docker build -t back-ventas .

    docker run -d -p 8080:8080 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${var.db_password} \
      --restart always \
      --name ventas \
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
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.publica_2.id
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

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

    docker run -d -p 8081:8081 \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${var.db_password} \
      --restart always \
      --name despachos \
      back-despachos
  EOF

  tags = { Name = "ec2-back-despachos" }
  depends_on = [aws_db_instance.mysql]
}
