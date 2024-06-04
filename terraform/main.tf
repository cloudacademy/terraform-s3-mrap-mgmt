locals {
  run_id = "prod"
}

module "role-s3-replication" {
  source = "./modules/role"

  saml_enabled      = false
  assumable_service = ["s3.amazonaws.com"]
  name              = "s3-replication"
}

module "kms-source" {
  source = "./modules/kms"

  kms_key_alias       = join("", ["bucket-key-replication-source-kms", local.run_id])
  kms_key_description = "Example KMS key for source S3 bucket"
}

module "kms-dest" {
  providers = {
    aws = aws.us-west-2
  }
  source = "./modules/kms"

  kms_key_alias       = join("", ["bucket-key-replication-dest-kms", local.run_id])
  kms_key_description = "Example KMS key for destination S3 bucket"
}

module "s3-source" {
  source = "./modules/s3"

  kms_key_arn                  = module.kms-source.kms_key_arn
  apply_bucket_request_metrics = true
  core_backups_retention       = "NOBACKUP"

  ########################################################################
  # uncomment the below code only after the creation of buckets in step 1
  ########################################################################
  # replication_role_arns = [module.role-s3-replication.role_arn]

  # replication_configuration = {
  #   role_name = module.role-s3-replication.role_name
  #   rules = [
  #     {
  #       id       = "bar"
  #       status   = "Enabled"
  #       priority = 1

  #       destination = {
  #         bucket             = "DESTINATION_BUCKET_ARN_GOES_HERE"
  #         storage_class      = "STANDARD"
  #         replica_kms_key_id = "DESTINATION_KMS_KEY_ARN_GOES_HERE"
  #       }

  #       filter = {
  #         prefix = "logs"
  #         tags = {
  #           ReplicateMe = "Yes"
  #         }
  #       }
  #     }
  #   ]
  # }
}

module "s3-dest" {
  providers = {
    aws = aws.us-west-2
  }
  source = "./modules/s3"

  kms_key_arn                  = module.kms-dest.kms_key_arn
  apply_bucket_request_metrics = true
  core_backups_retention       = "NOBACKUP"

  ############################################################################
  #uncomment the below code only after provisioning of the bucket in step 1
  ############################################################################
  # replication_role_arns = [module.role-s3-replication.role_arn]

  # replication_configuration = {
  #   role_name = module.role-s3-replication.role_name
  #   rules = [
  #     {
  #       id       = "bar"
  #       status   = "Enabled"
  #       priority = 1

  #       destination = {
  #         bucket             = "SOURCE_BUCKET_ARN_GOES_HERE"
  #         storage_class      = "STANDARD"
  #         replica_kms_key_id = "SOURCE_KMS_KEY_ARN_GOES_HERE"
  #       }

  #       filter = {
  #         prefix = "logs"
  #         tags = {
  #           ReplicateMe = "Yes"
  #         }
  #       }
  #     }
  #   ]
  # }
}
