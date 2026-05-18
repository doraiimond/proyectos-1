# ─────────────────────────────────────────
# PROVIDER & BACKEND
# ─────────────────────────────────────────

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Estado remoto en S3 (creado manualmente una sola vez antes del primer apply)
  # Instrucciones: ver README.md
  backend "s3" {
    bucket = "proyecto-terraform-state"
    key    = "proyecto-semestral/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
