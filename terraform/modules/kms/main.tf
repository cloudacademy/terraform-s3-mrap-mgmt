terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }
}

resource "aws_kms_key" "key" {
  description             = var.kms_key_description
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.key.key_id
}
