# DNA CodeArtifact

Terraform module for creating CodeArtifact domains and repositories.

## Requirements

In order to use this module, you must be using version 3.14.1 or higher of the
`hashicorp/aws` provider.

## Example Usage

Replace `<<latest-tag-version>>` with the latest tag version number, for
example `v1.4.1`.

```terraform
module "aws_tags" {
  source = XYZ

  foo = "foo"
  bar = "bar"
}

module "rds" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/rds?ref=<<latest-tag-version>>"

  base_tags                    = module.aws_tags.value
  domain_name                  = local.domain_name
  repository_name              = local.repository_name
  external_upstream_connection = local.external_upstream_connection
  domain_policy                = data.aws_iam_policy_document.domain_policy.json
  repository_policy            = data.aws_iam_policy_document.repository_policy.json
}
```
