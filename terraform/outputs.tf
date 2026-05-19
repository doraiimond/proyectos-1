# ─────────────────────────────────────────
# OUTPUTS
# El frontend se construye y sube a S3 desde
# el workflow de GitHub Actions, NO desde
# null_resource (evita dependencias de SO local)
# ─────────────────────────────────────────

output "alb_url" {
  description = "URL del Load Balancer (backends)"
  value       = "http://${aws_lb.alb.dns_name}"
}

output "frontend_url" {
  description = "URL del frontend en S3"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "ec2_ventas_ip" {
  description = "IP pública EC2 ventas"
  value       = aws_instance.backend["ventas"].public_ip
}

output "ec2_despachos_ip" {
  description = "IP pública EC2 despachos"
  value       = aws_instance.backend["despachos"].public_ip
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.mysql.address
  sensitive   = true
}

output "db_password_generado" {
  description = "Contraseña generada para la DB (guardada en el tfstate)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 del frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "alb_dns_name" {
  description = "DNS del ALB (usado por el workflow para buildear el frontend)"
  value       = aws_lb.alb.dns_name
}
