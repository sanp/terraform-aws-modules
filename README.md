# Terraform AWS Modules

Collection of helper modules used for generating AWS resources with Terraform.
There are helper modules for:

  - Code Artifact
  - Dynamo
  - Lambdas
  - RDS
  - S3
  - SNS
  - SQS
  - Kinesis

For more info on the individual modules, see the READMEs for those modules.

## Example Usage

Replace `<<latest-tag-version>>` with the latest tag version number, for
example `v1.4.1`.

```terraform
module "aws_tags" {
  source = XYZ

  foo = "foo"
  bar = "bar"
}

module "s3" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/s3?ref=<<latest-tag-version>>"

  base_tags   = module.aws_tags.value
  bucket_name = "foobar"
}

module "dynamo" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/dynamo?ref=<<latest-tag-version>>"

  base_tags   = module.aws_tags.value
  table_name  = var.table_name
  table_key   = var.catalog_table_key
  table_items = var.data_source_tokens
}

module "secrets" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/secrets?ref=<<latest-tag-version>>"

  base_tags          = module.aws_tags.value
  secret_name        = "foo"
  secret_description = "bar"
  secret             = "baz"
}
```
