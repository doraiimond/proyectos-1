# ─────────────────────────────────────────
# S3 - FRONTEND ESTÁTICO
# ─────────────────────────────────────────

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "frontend" {
  bucket        = "proyecto-frontend-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags          = { Name = "frontend-bucket" }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

resource "aws_s3_bucket_policy" "frontend_public" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

resource "aws_ecr_repository" "back_ventas" {
  name         = "proyecto-back-ventas"
  force_delete = true
  tags         = { Name = "ecr-back-ventas" }
}

resource "aws_ecr_repository" "back_despachos" {
  name         = "proyecto-back-despachos"
  force_delete = true
  tags         = { Name = "ecr-back-despachos" }
}
