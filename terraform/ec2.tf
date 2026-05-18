# ─────────────────────────────────────────
# KEY PAIR (clave viene de variable / secret de GitHub)
# ─────────────────────────────────────────

resource "aws_key_pair" "deployer" {
  key_name   = "proyecto-key"
  public_key = var.ssh_public_key
}

# ─────────────────────────────────────────
# AMI DINÁMICA (siempre la más reciente)
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
# EC2 - BACKENDS (usando for_each)
# ─────────────────────────────────────────

locals {
  backends = {
    ventas = {
      subnet    = aws_subnet.publica_1.id
      port      = 8080
      repo_path = "back-Ventas_SpringBoot/Springboot-API-REST"
      image     = "back-ventas"
      name      = "ventas"
    }
    despachos = {
      subnet    = aws_subnet.publica_2.id
      port      = 8081
      repo_path = "back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO"
      image     = "back-despachos"
      name      = "despachos"
    }
  }
}

resource "aws_instance" "backend" {
  for_each                    = local.backends
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = each.value.subnet
  vpc_security_group_ids      = [aws_security_group.sg_backend.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
  depends_on                  = [aws_db_instance.mysql]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user_data.log 2>&1

    yum update -y
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Esperar que Docker esté listo
    until docker info > /dev/null 2>&1; do
      echo "Esperando Docker..."
      sleep 5
    done

    # Esperar que la DB esté lista
    until docker run --rm mysql:8 mysqladmin ping \
      -h ${aws_db_instance.mysql.address} \
      -u${var.db_username} \
      -p${random_password.db_password.result} \
      --silent 2>/dev/null; do
      echo "Esperando RDS..."
      sleep 15
    done

    cd /home/ec2-user
    git clone https://github.com/doraiimond/proyectos-1.git proyecto
    cd proyecto/proyecto-semestral/${each.value.repo_path}

    docker build -t ${each.value.image} .
    docker run -d \
      -p ${each.value.port}:${each.value.port} \
      -e DB_ENDPOINT=${aws_db_instance.mysql.address} \
      -e DB_PORT=3306 \
      -e DB_NAME=${var.db_name} \
      -e DB_USERNAME=${var.db_username} \
      -e DB_PASSWORD=${random_password.db_password.result} \
      --restart always \
      --name ${each.value.name} \
      ${each.value.image}

    echo "Backend ${each.value.name} iniciado correctamente"
  EOF

  tags = { Name = "ec2-back-${each.key}" }
}
