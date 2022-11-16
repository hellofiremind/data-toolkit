module "asset_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.SERVICE}-${var.BUILD_STAGE}-${data.aws_caller_identity.current.account_id}-asset-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_alias.deployment_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "s3-bucket_notification" {
  source      = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version     = "3.5.0"
  bucket      = module.asset_bucket.s3_bucket_id
  bucket_arn  = module.asset_bucket.s3_bucket_arn
  eventbridge = true
}

resource "aws_s3_object" "input_data_folder" {
  bucket = module.asset_bucket.s3_bucket_id
  acl    = "private"
  key    = "input_data/"
  source = "/dev/null"
}

resource "aws_s3_object" "query_results_folder" {
  bucket = module.asset_bucket.s3_bucket_id
  acl    = "private"
  key    = "query_results/"
  source = "/dev/null"
}