# DNA Terraform RDS

Terraform module for creating RDS DB instances, as well as a basic security
group for that DB instance. The security group will have all ingress and egress
closed by default. If you wish to grant certain apps access to this DB
instance, you can do that by applying rules to the security group after it is
created.

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

  base_tags                  = module.aws_tags.value
  name                       = "foo"
  id                         = "bar"
  username                   = "baz"
  vpc_id                     = var.vpc_id
  db_subnet_group_name       = var.db_subnet_group_name
  allocated_storage          = 100
}
```
