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

# REGION 1 (us-east-1)
# ====================================

data "aws_vpc" "region1" {
  # provider = aws.us-west-2

  default = true
  state   = "available"
}

data "aws_subnet" "region1" {
  # provider = aws.us-west-2

  vpc_id            = data.aws_vpc.region1.id
  availability_zone = "us-east-1a"
  state             = "available"
}

module "vpc-endpoint-s3-global-region1" {
  source = "./modules/vpc-endpoint"

  private_dns_only_for_inbound_resolver_endpoint = false
  configuration = {
    service_name = "com.amazonaws.s3-global.accesspoint"
    subnet_type  = "Private"
    region       = "us-east-1"
  }

  vpc_id     = data.aws_vpc.region1.id
  subnet_ids = [data.aws_subnet.region1.id]
}

# REGION 2 (us-west-2)
# ====================================

data "aws_vpc" "region2" {
  provider = aws.us-west-2

  default = true
  state   = "available"
}

data "aws_subnet" "region2" {
  provider = aws.us-west-2

  vpc_id            = data.aws_vpc.region2.id
  availability_zone = "us-west-2a"
  state             = "available"
}

module "vpc-endpoint-s3-global-region2" {
  providers = {
    aws = aws.us-west-2
  }
  source = "./modules/vpc-endpoint"

  private_dns_only_for_inbound_resolver_endpoint = false
  configuration = {
    service_name = "com.amazonaws.s3-global.accesspoint"
    subnet_type  = "Private"
    region       = "us-west-2"
  }

  vpc_id     = data.aws_vpc.region2.id
  subnet_ids = [data.aws_subnet.region2.id]
}

# S3 MRAP
# ====================================

module "s3-mrap" {
  source = "./modules/s3-control"

  create_mrap       = true
  mrap_name         = "example-test-mrap"
  mrap_bucket_names = [module.s3-source.bucket_name, module.s3-dest.bucket_name]
}
