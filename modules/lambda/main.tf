##
# Encryption: KMS
##

# Use KMS to encrypt lambda environment values
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.name}."
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags = merge(
    var.base_tags,
    { "Lambda" = var.name }
  )
}

##
# Source files
##

data "archive_file" "archive" {
  # Only create the archive file if the source of the lambda's code is local.
  # If var.source_is_s3 is true, the archive file data source will not be
  # created.
  count = (var.source_is_s3 ? 0 : 1)

  type        = var.archive_type
  output_path = "${path.module}/dist/${var.name}.${var.archive_type}"

  # If the var.empty variable is set to true, create an empty lambda
  dynamic "source" {
    for_each = range(var.empty ? 1 : 0)
    content {
      content  = "Empty lambda."
      filename = var.empty_filename
    }
  }

  # If var.empty is not true, then create the lambda based on either the source
  # file or source directory.
  source_file = (! var.empty && var.source_is_file ? var.source_path : null)
  source_dir  = (! var.empty && var.source_is_file ? null : var.source_path)
}

##
# Security group
##

# If configure_vpc is set to true, then create a security group for the lambda.
resource "aws_security_group" "lambda_sg" {
  count = (var.configure_vpc ? 1 : 0)

  # Use name_prefix instead of name to force a destroy and replacement when
  # making changes to security group resources.
  name_prefix            = "${var.name}-security-group"
  description            = "Security group for ${var.name} lambda."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.sg_revoke_rules_on_delete

  lifecycle {
    # Interpolations are not allowed in lifecycle blocks.
    create_before_destroy = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.base_tags,
    { "Lambda Name" = var.name }
  )
}

##
# Optional dead letter queue
##

resource "aws_sqs_queue" "dead_letter_queue" {
  count = (var.create_dead_letter_queue ? 1 : 0)

  name                      = "${var.name}-dead-letter-queue"
  delay_seconds             = var.dlq_delay_seconds
  max_message_size          = var.dlq_max_message_size
  message_retention_seconds = var.dlq_message_retention_seconds
  receive_wait_time_seconds = var.dlq_receive_wait_time_seconds

  tags = merge(
    var.base_tags,
    {
      "Name"   = var.name,
      "Lambda" = var.name,
    }
  )
}

##
# Lambda resource
##

# Lambda
resource "aws_lambda_function" "lambda" {
  function_name                  = var.name
  description                    = var.description
  kms_key_arn                    = aws_kms_key.kms_key.arn
  role                           = aws_iam_role.lambda_role.arn
  filename                       = (! var.source_is_s3 ? data.archive_file.archive[0].output_path : null)
  source_code_hash               = (! var.source_is_s3 ? data.archive_file.archive[0].output_base64sha256 : null)
  s3_bucket                      = (var.source_is_s3 ? var.s3_bucket : null)
  s3_key                         = (var.source_is_s3 ? var.s3_key : null)
  handler                        = var.handler
  runtime                        = var.runtime
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # If environment variables are passed into this lambda, they are configured
  # here.
  dynamic "environment" {
    for_each = range(length(var.env_variables) > 0 ? 1 : 0)
    content {
      variables = var.env_variables
    }
  }

  # If create_dead_letter_queue is set to true, this block will be configured.
  dynamic "dead_letter_config" {
    for_each = range(var.create_dead_letter_queue ? 1 : 0)
    content {
      target_arn = aws_sqs_queue.dead_letter_queue[0].arn
    }
  }

  # If vpc_config is set to true, this block will be configured.
  dynamic "vpc_config" {
    for_each = range(var.configure_vpc ? 1 : 0)
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = (var.configure_vpc ? [aws_security_group.lambda_sg[0].id] : [])
    }
  }

  tags = merge(
    var.base_tags,
    {
      "Name"           = var.name,
      "Code Repo"      = var.git_repo,
      "KMS Encrypted"  = true,
      "VPC Configured" = var.configure_vpc,
    }
  )
}
