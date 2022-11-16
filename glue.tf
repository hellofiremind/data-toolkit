# GLUE DATABASE
resource "aws_glue_catalog_database" "db" {
  name = "${var.SERVICE}-${var.BUILD_STAGE}-db"
}

# GLUE CRAWLER S3 TARGET
resource "aws_glue_crawler" "crawler_s3" {
  database_name = aws_glue_catalog_database.db.name
  name          = "${var.SERVICE}-${var.BUILD_STAGE}-crawler-s3"
  role          = aws_iam_role.glue_role.arn
  table_prefix  = "${var.SERVICE}_${var.BUILD_STAGE}_"
  s3_target {
    path = "s3://${module.asset_bucket.s3_bucket_id}/${aws_s3_object.input_data_folder.key}"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

# GLUE ROLE
data "aws_iam_policy_document" "glue_role_policy" {
  statement {
    sid = "S3"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "Glue"

    actions = [
      "glue:*"
    ]

    resources = ["*"]
  }

  statement {
    sid = "CloudwatchLogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "KMS"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "glue_trust_relationship_policy" {
  statement {
    sid = "AllowGlue"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "${var.SERVICE}-${var.BUILD_STAGE}-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_trust_relationship_policy.json
}

resource "aws_iam_policy" "glue_policy" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-glue-policy"
  description = "${var.SERVICE}-${var.BUILD_STAGE}-glue-policy"
  policy      = data.aws_iam_policy_document.glue_role_policy.json
}

resource "aws_iam_role_policy_attachment" "glue_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
