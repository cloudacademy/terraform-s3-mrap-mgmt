terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }
}

resource "aws_s3control_multi_region_access_point" "mrap" {
  count = var.create_mrap ? 1 : 0

  details {
    name = var.mrap_name

    region {
      bucket = var.mrap_bucket_names[0]
    }

    region {
      bucket = var.mrap_bucket_names[1]
    }
  }
}
