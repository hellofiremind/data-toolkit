resource "aws_ssm_parameter" "asset_bucket" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/asset_bucket"
  type  = "String"
  value = module.asset_bucket.s3_bucket_id
}

resource "aws_ssm_parameter" "event_bridge_rule_arn" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/event_bridge_rule_arn"
  type  = "String"
  value = aws_cloudwatch_event_rule.rule.arn
}

resource "aws_ssm_parameter" "step_function_arn" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/step_function_arn"
  type  = "String"
  value = aws_sfn_state_machine.step_function.arn
}

resource "aws_ssm_parameter" "glue_crawler_arn" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/glue_crawler_arn"
  type  = "String"
  value = aws_glue_crawler.crawler_s3.arn
}

resource "aws_ssm_parameter" "glue_database_name" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/glue_database_name"
  type  = "String"
  value = aws_glue_catalog_database.db.name
}

resource "aws_ssm_parameter" "athena_workgroup_arn" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/athena_workgroup_arn"
  type  = "String"
  value = aws_athena_workgroup.athena_workgroup.arn
}

resource "aws_ssm_parameter" "sns_topic_arn" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/sns_topic_arn"
  type  = "String"
  value = aws_sns_topic.user_updates.arn
}

resource "aws_ssm_parameter" "kms_key" {
  name  = "/${var.SERVICE}/${var.BUILD_STAGE}/kms_key"
  type  = "String"
  value = aws_kms_key.deployment_key.id
}
