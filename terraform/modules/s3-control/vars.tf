# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "create_mrap" {
  description = "Whether to create MRAP or not"
  type        = bool
}

variable "mrap_name" {
  description = "The name of the MRAP"
  type        = string
}

variable "mrap_bucket_names" {
  description = "The bucket names for the MRAP"
  type        = list(string)
}
