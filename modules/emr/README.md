# EMR Module

Terraform module for deploying EMR clusters.

This module creates the following:

  - An EMR cluster
  - Roles for the cluster:
      - An EMR Role: this allows Amazon EMR to call other AWS services on your
          behalf when provisioning and performing service-level actions. This
          role is required for all clusters. For more info, see:
          https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
      - An EC2 Role: Application processes that run on top of the Hadoop ecosystem on
         cluster instances use this role when they call other AWS services. For
         more info, see:
         https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
      - An Autoscaling Role : Allows additional actions for dynamically scaling
         environments. Required only for clusters that use automatic scaling in
         Amazon EMR. For more info, see:
         https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
  - Security groups:
      - Master security group:
          - Allows SSH'ing into the master node
          - Allows inbound traffic from the other security groups
          - Allows all egress traffic
      - Slave security group:
          - Does not allow SSH'ing into
          - Allows inbound traffic from the other security groups
          - Allows all egress traffic
      - Service access security group:
          - Does not allow SSH'ing into
          - Allows inbound traffic from the master security group
          - Allows all egress traffic

If you need to provide this EMR cluster with additional access permissions, you
can attach policies to any of these roles. The names and ARNs of each role are
returned as outputs of this module; you can attach additional policies to any
of the roles after they are created.

## Example Usage

Replace `<<latest-tag-version>>` with the latest tag version number, for
example `v1.4.1`.

```terraform
module "aws_tags" {
  source = XYZ

  foo = "foo"
  bar = "bar"
}

module "emr" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/emr?ref=<<latest-tag-version>>"

  base_tags     = module.aws_tags.value
  name          = "foobar"
  ...
}
```

## Bootstrap Actions

Bootstrap actions are run after the server is provisioned but before installing
the applications. For example, if you have set the `applications` input
variable to `["Hadoop", "Spark"]`, then bootstrap actions are run before Hadoop
and Spark are installed on your cluster.

You can optionally specify bootstrap actions to be run when setting up your
cluster by providing a value to the `bootstrap_actions` variable. To do that,
you can define bootstrap actions with code similar to the below code.

Define some bootstrap actions as executable scripts which live in a
subdirectory of your terraform repository. For example, let's say you have the
following script in a directory called `bootstrap`:

`some-script`:
```sh
#!/bin/bash

ARG1=$1
ARG2=$2

echo ${ARG1}
echo ${ARG2}
```

You can execute this bootstrap action by calling this module with the following
code:

```terraform
# Create an S3 bucket and upload the bootstrap action script to that bucket
module "s3" {
  source       = "git@github.com:sanp/terraform-aws-modules.git//modules/s3?ref=<<latest-tag-version>>"
  base_tags    = module.aws_tags.value
  bucket_name  = "your-bucket-name"
  upload_files = [
    {
      s3_key    = "some-script",
      file_path = "${abspath(path.module)}/bootstrap/some-script"
    },
  ]
}


module "emr" {
  source = "git@github.com:sanp/terraform-aws-modules.git//modules/emr?ref=<<latest-tag-version>>"
  ...
  bootstrap_actions = [
    {
      name = "some-script"
      path = "s3://your-bucket-name/some-script"
      args = [
        "Foo",
        "Bar",
      ]
    },
  ]
}
```

## Steps

Steps are run after the applications have been installed on your cluster.

By default, the cluster created by this module will run a step to enable hadoop
debug logging. Logs will be stored in the S3 path specified by the `log_uri`
input variable to this module.

You can enable any additional steps by supplying a value to the `extra_steps`
input variable to this module:

```terraform
locals {
  steps = [{
    name              = "some-script"
    action_on_failure = "TERMINATE_CLUSTER"
    hadoop_jar_step = {
      # This JAR, provided by Amazon, runs the script passed to it as its first
      # argument.
      jar        = "s3://${local.aws_region}.elasticmapreduce/libs/script-runner/script-runner.jar"
      args       = ["s3://path/to/some-script"]
      main_class = null
      properties = null
    }
  }]
```
