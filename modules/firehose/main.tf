resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = var.name
  destination = var.firehose_destination

  tags = merge(
    var.base_tags,
    {
      "Name"      = var.name,
      "S3 Bucket" = var.sink_bucket_arn,
      "Lambda"    = var.lambda_arn,
    }
  )

  server_side_encryption {
    enabled  = var.sse_enabled
    key_type = var.cmk_type
    key_arn  = var.key_arn
  }

  extended_s3_configuration {
    role_arn    = aws_iam_role.firehose_role.arn
    bucket_arn  = var.sink_bucket_arn
    buffer_size = var.buffer_size

    processing_configuration {
      enabled = var.processing_enabled

      processors {
        type = var.processing_type

        parameters {
          parameter_name  = var.processor_parameter_name
          parameter_value = "${var.lambda_arn}:$LATEST"
        }
      }
    }
  }
}
