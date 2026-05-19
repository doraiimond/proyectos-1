# ─────────────────────────────────────────
# OUTPUTS - URLs importantes al terminar
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
  value       = aws_instance.back_ventas.public_ip
}

output "ec2_despachos_ip" {
  description = "IP pública EC2 despachos"
  value       = aws_instance.back_despachos.public_ip
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.mysql.address
}

resource "null_resource" "build_frontend" {
  triggers = {
    alb_url = aws_lb.alb.dns_name
  }

  provisioner "local-exec" {
    command     = <<-EOF
      cd /c/Users/aceve/Documents/GitHub/proyectos-1/proyecto-semestral/front_despacho && \
      mkdir -p dist_output && \
      docker build --no-cache --build-arg VITE_API_URL=http://${aws_lb.alb.dns_name} -t frontend . && \
      docker run --rm -v "C:\\Users\\aceve\\Documents\\GitHub\\proyectos-1\\proyecto-semestral\\front_despacho\\dist_output:/output" frontend sh -c "cp -r /usr/share/nginx/html/* /output/" && \
      aws s3 sync dist_output/ s3://${aws_s3_bucket.frontend.bucket} --delete
    EOF
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]
  }

  depends_on = [aws_lb.alb, aws_s3_bucket.frontend]
}