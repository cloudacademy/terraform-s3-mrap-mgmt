output "source_kms_key_arn" {
  value = module.kms-source.kms_key_arn
}

output "source_bucket_name" {
  value = module.s3-source.bucket_name
}

output "source_bucket_arn" {
  value = module.s3-source.bucket_arn
}

output "destination_kms_key_arn" {
  value = module.kms-dest.kms_key_arn
}

output "destination_bucket_name" {
  value = module.s3-dest.bucket_name
}

output "destination_bucket_arn" {
  value = module.s3-dest.bucket_arn
}
