# Create a default role for the lambda: allow the lambda to configure a VPC and
# access logs. Additional access policies which the lambda needs can be added
# later as inline policies through a separate process.

##
# Policies
##

# Assume role policy for lambda.
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  version = var.policy_version
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Policy to allow a lambda function to execute.
data "aws_iam_policy_document" "lambda_access" {
  version = var.policy_version
  statement {
    sid    = "lambdaAccess"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:*:*:*",
    ]
  }
}

# In order to configure VPC access to the lambdas, the following policy must be
# applied.
data "aws_iam_policy_document" "vpc_access" {
  version = var.policy_version
  statement {
    sid    = "VPCAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = [
      "*",
    ]
  }
}

# Policy to allow a resource to create and write to logs.
data "aws_iam_policy_document" "log_access" {
  version = var.policy_version
  statement {
    sid    = "logAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

locals {
  default_policies = [
    data.aws_iam_policy_document.lambda_access.json,
    data.aws_iam_policy_document.vpc_access.json,
    data.aws_iam_policy_document.log_access.json,
  ]
  default_policies_map = { for index, policy in local.default_policies : index => policy }
}

##
# Role
##

resource "aws_iam_role" "lambda_role" {
  name                  = "${var.name}-role"
  description           = "Role for the ${var.name} lambda."
  force_detach_policies = var.role_force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = merge(
    var.base_tags,
    {
      "Lambda" = var.name,
    }
  )
}

##
# Attach policies
##

resource "aws_iam_role_policy" "policies" {
  for_each = local.default_policies_map

  name   = jsondecode(each.value)["Statement"][0]["Sid"]
  role   = aws_iam_role.lambda_role.id
  policy = each.value
}
