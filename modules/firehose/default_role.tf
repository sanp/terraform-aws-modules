data "aws_iam_policy_document" "assume_firehose_policy" {
  version = var.policy_version
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_s3_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      var.sink_bucket_arn,
      "${var.sink_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${var.name}-firehose_role"
  assume_role_policy = data.aws_iam_policy_document.assume_firehose_policy.json
}

resource "aws_iam_role_policy" "firehose_s3_policy" {
  name   = "${var.name}-s3policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.assume_s3_policy.json
}

data "aws_iam_policy_document" "assume_lambda_policy_attachment" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      var.lambda_arn,
      "${var.lambda_arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "firehose_lambda_policy" {
  name   = "${var.name}-lambdapolicy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.assume_lambda_policy_attachment.json
}
