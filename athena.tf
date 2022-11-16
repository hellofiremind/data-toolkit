resource "aws_athena_workgroup" "athena_workgroup" {
  name          = "${var.SERVICE}-${var.BUILD_STAGE}-athena-workgroup"
  force_destroy = true
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.asset_bucket.s3_bucket_id}/${aws_s3_object.query_results_folder.key}"
    }
  }
}
