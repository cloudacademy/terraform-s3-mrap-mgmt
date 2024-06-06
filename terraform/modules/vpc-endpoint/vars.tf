# variable "version" {
#   description = "The module version"
#   type        = string
# }

variable "private_dns_only_for_inbound_resolver_endpoint" {
  description = "Private DNS only for inbound resolver endpoint"
  type        = bool
}

variable "configuration" {
  description = "The configuration for the VPC endpoint"
  type = object({
    service_name = string
    subnet_type  = string
    region       = string
  })
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
  default     = "VPC_ID_HERE"
}

variable "subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)
  default     = ["SUBNET_IDS_HERE"]
}

variable "security_group_ids" {
  description = "The security group IDs"
  type        = list(string)
  default     = ["SECURITY_GROUP_IDS_HERE"]
}
