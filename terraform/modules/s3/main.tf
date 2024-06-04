terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 12
  special = false
  upper   = false

  keepers = {
    lab_version = var.lab_version
  }
}

locals {
  s3 = {
    bucket_name = "app-id-12345-dep-id-12345-uu-id-${random_string.bucket_suffix.result}"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.s3.bucket_name

  tags = {
    #BUCKET_TAGS_GO_HERE
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  count  = var.lifecycle_rules == null ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules == null ? [] : var.lifecycle_rules

    content {
      id     = rule.value.id
      status = "Enabled"

      filter {
        prefix = rule.value.filter.prefix
      }

      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : rule.value.expiration

        content {
          days = expiration.value.days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions == null ? [] : rule.value.transitions

        content {
          storage_class = transition.value.storage_class
          days          = transition.value.days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration == null ? [] : [rule.value.noncurrent_version_expiration]

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count = var.replication_configuration == null ? 0 : 1
  # provider = aws.central
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.bucket]

  role = var.replication_role_arns[0]

  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = try(var.replication_configuration.rules, [])

    content {
      id     = rule.value.id
      status = rule.value.status

      delete_marker_replication {
        status = "Disabled"
      }

      source_selection_criteria {
        replica_modifications {
          status = "Enabled"
        }
        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class
        encryption_configuration {
          replica_kms_key_id = rule.value.destination.replica_kms_key_id
        }
      }

      filter {
        and {
          prefix = rule.value.filter.prefix
          tags   = rule.value.filter.tags
        }
        prefix = rule.value.filter.prefix
      }
    }
  }
}
