terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }
}

resource "aws_vpc_endpoint" "endpoint" {
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
  service_name        = var.configuration.service_name
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = var.private_dns_only_for_inbound_resolver_endpoint
}
