# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "kms_key_alias" {
  description = "The alias for the KMS key"
  type        = string
}

variable "kms_key_description" {
  description = "The description for the KMS key"
  type        = string
}
