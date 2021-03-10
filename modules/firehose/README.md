# Firehose Module

Terraform module for deploying firehose delivery stream.

This module creates a firehose delivery stream with transformation by a lambda 
function.

## Example Usage

Replace `<<latest-tag-version>>` with the latest tag version number, for
example `v1.6.0`.

```terraform
module "aws_tags" {
  source = XYZ

  foo = "foo"
  bar = "bar"
}

module "firehose" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/firehose?ref=<<latest-tag-version>>"

  base_tags        = var.aws_tags.value
  name             = var.firehose_name
  sink_bucket_arn  = var.s3_sink_bucket_arn
  lambda_arn       = var.lambda_arn
}
```
