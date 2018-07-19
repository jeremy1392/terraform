variable "zone_account_id" {
  type = "string"
}

provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.zone_account_id}:role/full-admin"
  }
}
