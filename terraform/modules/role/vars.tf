# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "saml_enabled" {
  description = "Whether SAML is enabled"
  type        = bool
}

variable "assumable_service" {
  description = "The services that can assume the role"
  type        = list(string)
}

variable "name" {
  description = "The name of the role"
  type        = string
}
