# Template file for step function definition
data "template_file" "json_template" {
  template = file("${path.cwd}/config/stepfunction.json")
  vars = {
    GLUE_CRAWLER_NAME = aws_glue_crawler.crawler_s3.name
    REGION            = var.AWS_REGION
    SERVICE_NAME      = "${var.SERVICE}-${var.BUILD_STAGE}"
    GLUE_DATABASE     = aws_glue_catalog_database.db.name
    GLUE_TABLE        = "${var.SERVICE}_${var.BUILD_STAGE}_input_data"
    WORKGROUP_NAME    = aws_athena_workgroup.athena_workgroup.name
    SNS_TOPIC_ARN     = aws_sns_topic.user_updates.arn
  }
}

resource "aws_sfn_state_machine" "step_function" {
  name     = "${var.SERVICE}-${var.BUILD_STAGE}-step-function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = data.template_file.json_template.rendered
}
