# ─────────────────────────────────────────
# VPC
# ─────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "proyecto-vpc" }
}

# ─────────────────────────────────────────
# SUBREDES PÚBLICAS (2 zonas para ALB)
# ─────────────────────────────────────────
resource "aws_subnet" "publica_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "subred-publica-1" }
}

resource "aws_subnet" "publica_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "subred-publica-2" }
}

# ─────────────────────────────────────────
# SUBREDES PRIVADAS (2 zonas para RDS)
# ─────────────────────────────────────────
resource "aws_subnet" "privada_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "subred-privada-1" }
}

resource "aws_subnet" "privada_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "subred-privada-2" }
}

# ─────────────────────────────────────────
# INTERNET GATEWAY
# ─────────────────────────────────────────
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "proyecto-igw" }
}

# ─────────────────────────────────────────
# ROUTE TABLE PÚBLICA
# ─────────────────────────────────────────
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-publica" }
}

resource "aws_route_table_association" "publica_1" {
  subnet_id      = aws_subnet.publica_1.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_2" {
  subnet_id      = aws_subnet.publica_2.id
  route_table_id = aws_route_table.publica.id
}

# ─────────────────────────────────────────
# NAT GATEWAY (para que EC2 privadas salgan a internet)
# ─────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publica_1.id
  tags = { Name = "proyecto-nat" }
  depends_on = [aws_internet_gateway.igw]
}

# ─────────────────────────────────────────
# ROUTE TABLE PRIVADA
# ─────────────────────────────────────────
resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "rt-privada" }
}

resource "aws_route_table_association" "privada_1" {
  subnet_id      = aws_subnet.privada_1.id
  route_table_id = aws_route_table.privada.id
}

resource "aws_route_table_association" "privada_2" {
  subnet_id      = aws_subnet.privada_2.id
  route_table_id = aws_route_table.privada.id
}
