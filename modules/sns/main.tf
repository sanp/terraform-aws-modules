resource "aws_sns_topic" "topic" {
  name         = var.name
  display_name = var.name
  tags = merge(
    var.base_tags,
    {
      "Name"              = var.name,
      "S3 Bucket Trigger" = var.s3_bucket,
    }
  )
}

resource "aws_sns_topic_policy" "topic_policy" {
  arn = aws_sns_topic.topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "allow-s3-to-publish-to-sns"
  version   = var.policy_version

  statement {
    sid    = "${var.s3_bucket}-s3-to-sns"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Publish",
    ]
    resources = [
      aws_sns_topic.topic.arn,
    ]
    condition {
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:s3:::${var.s3_bucket}",
      ]
    }
  }
}

# Subscribe the topic to the S3 bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket

  topic {
    topic_arn = aws_sns_topic.topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
