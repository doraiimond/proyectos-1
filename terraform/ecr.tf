# ─────────────────────────────────────────
# ECR REPOSITORIES
# ─────────────────────────────────────────

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
