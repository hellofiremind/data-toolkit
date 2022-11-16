data "template_file" "rule_template" {
  template = file("${path.cwd}/config/eventbridge.json")
  vars = {
    BUCKET_NAME = module.asset_bucket.s3_bucket_id
    PREFIX      = aws_s3_object.input_data_folder.key
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  name          = "${var.SERVICE}-${var.BUILD_STAGE}-rule"
  event_pattern = data.template_file.rule_template.rendered
}

resource "aws_cloudwatch_event_target" "step_function" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = "SendToStepFunction"
  arn       = aws_sfn_state_machine.step_function.arn
  role_arn  = aws_iam_role.event_bridge_role.arn
}