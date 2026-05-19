# ─────────────────────────────────────────
# VARIABLES
# ─────────────────────────────────────────

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "bdd"  # igual que en docker-compose.yml
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "admin"
}

variable "ssh_public_key" {
  description = "Clave SSH pública para acceder a las EC2 (contenido del .pub)"
  type        = string
  sensitive   = true
}

variable "ecr_ventas_url" {
  description = "URL de la imagen ECR del backend ventas"
  type        = string
}

variable "ecr_despachos_url" {
  description = "URL de la imagen ECR del backend despachos"
  type        = string
}