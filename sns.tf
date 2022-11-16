resource "aws_sns_topic" "user_updates" {
  name = "${var.SERVICE}-${var.BUILD_STAGE}-user-updates"
}
