variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "111111111111"
}

variable "kms_key_alias" {
  description = "The alias for the KMS key"
  type        = string
  default     = "lab-kms-key"
}
