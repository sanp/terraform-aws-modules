locals {
  tags = merge(
    var.base_tags,
    { "EMR Cluster" = var.name }
  )
}

/*
 * Master Security Group
*/

resource "aws_security_group" "master" {
  name_prefix            = "${var.name}-master-sg"
  description            = "Master EMR Security Group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.sg_revoke_rules_on_delete
  tags                   = local.tags

  # Force create before destroy to avoid DependencyViolation errors when making
  # changes to security group resources. Note: interpolations are not allowed
  # inside of lifecycle blocks, so this must be hard-coded.
  lifecycle {
    create_before_destroy = true
  }
}

## Ingress

resource "aws_security_group_rule" "master_ssh_ingress" {
  description       = "Allow SSH access to the master SG."
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.master.id
}

## Egress

resource "aws_security_group_rule" "master_egress" {
  description       = "Allow all egress traffic."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.master.id
}

/*
 * Slave Security Group
*/

resource "aws_security_group" "slave" {
  name_prefix            = "${var.name}-slave-sg"
  description            = "Slave EMR Security Group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.sg_revoke_rules_on_delete
  tags                   = local.tags

  # Force create before destroy to avoid DependencyViolation errors when making
  # changes to security group resources. Note: interpolations are not allowed
  # inside of lifecycle blocks, so this must be hard-coded.
  lifecycle {
    create_before_destroy = true
  }
}

## Egress

resource "aws_security_group_rule" "slave_egress" {
  description       = "Allow all egress traffic."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.slave.id
}

/*
 * Service Access Security Group
*/

resource "aws_security_group" "service_access" {
  name_prefix            = "${var.name}-service-access-sg"
  description            = "Service access EMR Security Group"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.sg_revoke_rules_on_delete
  tags                   = local.tags

  # Force create before destroy to avoid DependencyViolation errors when making
  # changes to security group resources. Note: interpolations are not allowed
  # inside of lifecycle blocks, so this must be hard-coded.
  lifecycle {
    create_before_destroy = true
  }
}

## Ingress

resource "aws_security_group_rule" "service_access_master_ingress" {
  description              = "Allow ingress traffic from Master SG"
  protocol                 = "tcp"
  from_port                = 9443
  to_port                  = 9443
  type                     = "ingress"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.service_access.id
}

## Egress

resource "aws_security_group_rule" "service_access_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.service_access.id
}

/*
 EMR Role : Allows Amazon EMR to call other AWS services on your behalf when
 provisioning resources and performing service-level actions. This role is
 required for all clusters. For more info, see:
 https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/

data "aws_iam_policy_document" "assume_role_emr" {
  version = var.policy_version
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr" {
  name                  = "${var.name}-emr-role"
  description           = "EMR Role for the ${var.name} EMR cluster."
  force_detach_policies = var.role_force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.assume_role_emr.json

  tags = merge(
    var.base_tags,
    {
      "EMR Cluster" = var.name,
    }
  )
}

resource "aws_iam_role_policy_attachment" "emr" {
  role       = aws_iam_role.emr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

/*
 EC2 Role : Application processes that run on top of the Hadoop ecosystem on
 cluster instances use this role when they call other AWS services. For more
 info, see:
 https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/

data "aws_iam_policy_document" "assume_role_ec2" {
  version = var.policy_version
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  name                  = "${var.name}-ec2-role"
  description           = "EC2 Role for the ${var.name} EMR cluster."
  force_detach_policies = var.role_force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.assume_role_ec2.json

  tags = merge(
    var.base_tags,
    {
      "EMR Cluster" = var.name,
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}

/*
 Autoscaling Role : Allows additional actions for dynamically scaling
 environments. Required only for clusters that use automatic scaling in Amazon
 EMR. For more info, see:
 https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/

data "aws_iam_policy_document" "assume_role_autoscaling" {
  version = var.policy_version
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_autoscaling" {
  name                  = "${var.name}-ec2-autoscaling-role"
  description           = "EC2 autoscaling role for the ${var.name} EMR cluster."
  force_detach_policies = var.role_force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.assume_role_autoscaling.json

  tags = merge(
    var.base_tags,
    {
      "EMR Cluster" = var.name,
    }
  )
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "ec2_autoscaling" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

/*
 * EMR Cluster
*/

resource "aws_emr_cluster" "emr" {
  name                              = var.name
  release_label                     = var.release_label
  applications                      = var.applications
  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  ebs_root_volume_size              = var.ebs_root_volume_size
  configurations_json               = var.configurations_json
  scale_down_behavior               = var.scale_down_behavior
  service_role                      = aws_iam_role.emr.arn
  autoscaling_role                  = aws_iam_role.ec2_autoscaling.arn
  log_uri                           = "s3n://${var.log_bucket}/${var.name}/elasticmapreduce/"
  tags                              = local.tags

  ec2_attributes {
    subnet_id                         = var.subnet_id
    instance_profile                  = aws_iam_instance_profile.ec2.arn
    key_name                          = var.key_name
    emr_managed_master_security_group = aws_security_group.master.id
    emr_managed_slave_security_group  = aws_security_group.slave.id
    service_access_security_group     = aws_security_group.service_access.id
  }

  master_instance_group {
    name           = "${var.name}-master-instance-group"
    instance_type  = var.master_instance_group_instance_type
    instance_count = var.master_instance_group_instance_count
    bid_price      = var.master_instance_group_bid_price

    ebs_config {
      size                 = var.master_instance_group_ebs_size
      type                 = var.master_instance_group_ebs_type
      iops                 = var.master_instance_group_ebs_iops
      volumes_per_instance = var.master_instance_group_ebs_volumes_per_instance
    }
  }

  core_instance_group {
    name               = "${var.name}-core-instance-group"
    instance_type      = var.core_instance_group_instance_type
    instance_count     = var.core_instance_group_instance_count
    bid_price          = var.core_instance_group_bid_price
    autoscaling_policy = null

    ebs_config {
      size                 = var.core_instance_group_ebs_size
      type                 = var.core_instance_group_ebs_type
      iops                 = var.core_instance_group_ebs_iops
      volumes_per_instance = var.core_instance_group_ebs_volumes_per_instance
    }
  }

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_actions
    content {
      path = bootstrap_action.value.path
      name = bootstrap_action.value.name
      args = bootstrap_action.value.args
    }
  }

  # Enable debug logging by default
  step {
    name              = "Setup Hadoop Debugging"
    action_on_failure = "TERMINATE_CLUSTER"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  # Any additional steps can be added
  dynamic "step" {
    for_each = var.extra_steps
    content {
      name              = step.value.name
      action_on_failure = step.value.action_on_failure
      hadoop_jar_step {
        jar        = step.value.hadoop_jar_step["jar"]
        main_class = lookup(step.value.hadoop_jar_step, "main_class", null)
        properties = lookup(step.value.hadoop_jar_step, "properties", null)
        args       = lookup(step.value.hadoop_jar_step, "args", null)
      }
    }
  }

  lifecycle {
    ignore_changes = [step]
  }
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html
# https://www.terraform.io/docs/providers/aws/r/emr_instance_group.html
resource "aws_emr_instance_group" "task" {
  count = var.create_task_instance_group ? 1 : 0

  name           = "${var.name}-task-instance-group"
  cluster_id     = aws_emr_cluster.emr.id
  instance_type  = var.task_instance_group_instance_type
  instance_count = var.task_instance_group_instance_count

  ebs_config {
    size                 = var.task_instance_group_ebs_size
    type                 = var.task_instance_group_ebs_type
    iops                 = var.task_instance_group_ebs_iops
    volumes_per_instance = var.task_instance_group_ebs_volumes_per_instance
  }

  bid_price          = var.task_instance_group_bid_price
  ebs_optimized      = var.task_instance_group_ebs_optimized
  autoscaling_policy = var.task_instance_group_autoscaling_policy
}

resource "aws_emr_managed_scaling_policy" "core_instance_group_autoscaling_policy" {
  count = var.create_core_instance_group_autoscaling_policy ? 1 : 0

  cluster_id = aws_emr_cluster.emr.id
  compute_limits {
    unit_type                       = "Instances"
    minimum_capacity_units          = var.core_instance_group_minimum_capacity_units
    maximum_capacity_units          = var.core_instance_group_maximum_capacity_units
    maximum_ondemand_capacity_units = var.core_instance_group_minimum_ondemand_capacity_units
    maximum_core_capacity_units     = var.core_instance_group_maximum_core_capacity_units
  }
}
