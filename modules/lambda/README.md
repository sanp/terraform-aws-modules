# Lambda Module

Terraform module for deploying lambdas.

This module creates a lambda, as well as a security group for that lambda. If
your lambda needs access to another AWS resource, you can provide access with a
security group rule. Source code for the lambda may be provided as any of the
following:
  - A path to a file
      - To do this, set `source_is_file` to true and provide a file path as the
        value of `source_path`.
  - A path to a directory
      - To do this, set `source_is_file` to false and provide a directory path
      - as the value of `source_path`.
  - An S3 bucket and key
      - To do this, set `source_is_s3` to true and provide a value for
        `s3_bucket` and `s3_key`.
  - An empty lambda
      - To do this, set `empty` to true, and a lambda will be created with a
          single file containing the words "Empty lambda."

All environment variables for the lambda are KMS encrypted.

## Example Usage

Replace `<<latest-tag-version>>` with the latest tag version number, for
example `v1.4.1`.

```terraform
module "aws_tags" {
  source = XYZ

  foo = "foo"
  bar = "bar"
}

module "lambda" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/lambda?ref=<<latest-tag-version>>"

  base_tags     = var.base_tags
  name          = "${var.stack_prefix}-${each.key}"
  description   = "foo"
  source_path   = "/path/to/package.zip"
  handler       = "index.handler"
  git_repo      = var.git_address
  role          = var.role_arn
  env_variables = {"foo" = "bar"}
  configure_vpc = true
  vpc_id        = var.vpc_id
  subnet_ids    = var.subnet_ids
}
```
