# STEP FUNCTION ROLE
resource "aws_iam_role" "step_function_role" {
  name               = "${var.SERVICE}-${var.BUILD_STAGE}-step-function-role"
  assume_role_policy = data.aws_iam_policy_document.step_function_trust_relationship_policy.json
}

resource "aws_iam_role_policy_attachment" "step_function_role_attachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

data "aws_iam_policy_document" "step_function_trust_relationship_policy" {
  statement {
    sid = "AllowStepFunction"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "step_function_role_policy_attachment" {

  statement {
    sid = "Athena"

    actions = [
      "athena:startQueryExecution",
      "athena:stopQueryExecution",
      "athena:getQueryExecution",
      "athena:getDataCatalog",
      "athena:getQueryResults"
    ]

    resources = [
      aws_athena_workgroup.athena_workgroup.arn,
      "arn:aws:athena:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:datacatalog/*"
    ]
  }

  statement {
    sid = "S3"

    actions = [
      "s3:*"
    ]

    resources = [
      module.asset_bucket.s3_bucket_arn,
      "${module.asset_bucket.s3_bucket_arn}/*",
    ]
  }

  statement {
    sid = "Glue"

    actions = [
      "glue:*"
    ]

    resources = [
      aws_glue_crawler.crawler_s3.arn,
      "arn:aws:glue:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.db.arn,
      "arn:aws:glue:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:table/*"
    ]
  }

  statement {
    sid = "KMSDecrypt"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.deployment_key.arn,
      aws_kms_alias.deployment_key.arn
    ]
  }

  statement {
    sid = "SNS"

    actions = [
      "SNS:*"
    ]

    resources = [
      aws_sns_topic.user_updates.arn,
    ]
  }

}

resource "aws_iam_policy" "step_function_policy" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-step-function-policy"
  description = "${var.SERVICE}-${var.BUILD_STAGE}-step-function-policy"
  policy      = data.aws_iam_policy_document.step_function_role_policy_attachment.json
}

# EVENT BRIDGE ROLE

resource "aws_iam_role" "event_bridge_role" {
  name               = "${var.SERVICE}-${var.BUILD_STAGE}-event-bridge-role"
  assume_role_policy = data.aws_iam_policy_document.event_bridge_trust_relationship_policy.json
}

resource "aws_iam_role_policy_attachment" "event_bridge_role_attachment" {
  role       = aws_iam_role.event_bridge_role.name
  policy_arn = aws_iam_policy.event_bridge_policy.arn
}

data "aws_iam_policy_document" "event_bridge_trust_relationship_policy" {
  statement {
    sid = "AllowEventBridge"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "event_bridge_role_policy_attachment" {

  statement {
    sid = "StepFunction"

    actions = [
      "states:StartExecution"
    ]

    resources = [
      aws_sfn_state_machine.step_function.arn
    ]
  }

}

resource "aws_iam_policy" "event_bridge_policy" {
  name        = "${var.SERVICE}-${var.BUILD_STAGE}-event-bridge-policy"
  description = "${var.SERVICE}-${var.BUILD_STAGE}-event-bridge-policy"
  policy      = data.aws_iam_policy_document.event_bridge_role_policy_attachment.json
}