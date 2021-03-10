locals {
  dlq_name = "${var.name}-dead_letter_queue"
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = local.dlq_name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  tags = merge(
    var.base_tags,
    {
      "Name"      = var.name,
      "SNS Topic" = var.sns_topic,
      "DLQ"       = local.dlq_name
      "Lambda"    = var.lambda,
    }
  )
}

resource "aws_sqs_queue" "queue" {
  name                      = var.name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = var.max_recieve_count
  })

  tags = merge(
    var.base_tags,
    {
      "Name"      = local.dlq_name
      "SNS Topic" = var.sns_topic,
      "SQS Queue" = var.name
      "Lambda"    = var.lambda,
    }
  )
}


resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = data.aws_iam_policy_document.sqs_topic_policy.json
}

data "aws_iam_policy_document" "sqs_topic_policy" {
  policy_id = "allow-sns-to-send-message-to-sqs"
  version   = var.policy_version

  statement {
    sid    = "${var.name}-sns-to-sqs"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage",
    ]
    resources = [
      aws_sqs_queue.queue.arn,
    ]
    condition {
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
      values   = [var.sns_topic]
    }
  }
}

##
# Subscriptions
##

# Subscribe the SQS queue to the SNS topic
resource "aws_sns_topic_subscription" "sns_updates_sqs" {
  protocol  = "sqs"
  topic_arn = var.sns_topic
  endpoint  = aws_sqs_queue.queue.arn
}

# Trigger the lambda function from the SQS queue
resource "aws_lambda_event_source_mapping" "sqs_trigger_lambda" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = var.lambda
  batch_size       = var.lambda_batch_size
}
