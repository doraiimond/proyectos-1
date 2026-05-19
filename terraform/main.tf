provider "aws" {
  region = "us-east-1"
}

# ─────────────────────────────────────────
# VARIABLES
# ─────────────────────────────────────────
variable "db_name" {
  default = "bdd"
}
variable "db_username" {
  default = "root"
}
variable "db_password" {
  default = "Root1234!"
}
