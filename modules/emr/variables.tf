variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name of the EMR cluster to create."
}

variable "release_label" {
  type        = string
  description = "Release version of EMR. E.g.: emr-6.2.0"
}

variable "scale_down_behavior" {
  type        = string
  description = "The way instances scale down."
}

variable "ebs_root_volume_size" {
  type        = string
  description = "Volume size in GB of EBS root device volume."
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key to use. The key must exist already."
}

variable "log_bucket" {
  type        = string
  description = "Name of the bucket where logs for this cluster will be stored."
}

variable "configurations_json" {
  type        = string
  description = "A JSON string for supplying list of configurations for the EMR cluster."
  default     = null
}

variable "applications" {
  type        = list(string)
  description = "Case-insensitive list of applications to include in the cluster."
  default     = ["Hadoop", "Spark"]
}

variable "termination_protection" {
  type        = bool
  description = "Whether to enable termination protection."
  default     = true
}

variable "keep_job_flow_alive_when_no_steps" {
  type        = bool
  description = "Whether to run cluster with no steps, or when all steps are complete."
  default     = true
}

variable "role_force_detach_policies" {
  type        = bool
  description = "Specifies to force detaching any policies the role has before destroying it."
  default     = true
}

variable "policy_version" {
  type        = string
  description = "AWS policy language version. The latest is 2012-10-17."
  default     = "2012-10-17"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "subnet_id" {
  type        = string
  description = "VPC subnet ID."
}

variable "sg_revoke_rules_on_delete" {
  type    = bool
  default = true
}

##
# Instance group configs
##

# Master

variable "master_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Master instance group"
}

variable "master_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Master instance group. Must be 1 or 3."
  default     = 1
  validation {
    condition     = contains([1, 3], var.master_instance_group_instance_count)
    error_message = "The master_instance_group_instance_count must be 1 or 3."
  }
}

variable "master_instance_group_ebs_size" {
  type        = number
  description = "Master instances volume size, in gibibytes (GiB)"
}

variable "master_instance_group_ebs_type" {
  type        = string
  description = "Master instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "master_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Master volume supports"
  default     = null
}

variable "master_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Master instance group"
  default     = 1
}

variable "master_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Master instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

# Core

variable "core_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Core instance group"
}

variable "core_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Core instance group. Must be at least 1"
  default     = 1
}

variable "core_instance_group_ebs_size" {
  type        = number
  description = "Core instances volume size, in gibibytes (GiB)"
}

variable "core_instance_group_ebs_type" {
  type        = string
  description = "Core instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "core_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Core volume supports"
  default     = null
}

variable "core_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Core instance group"
  default     = 1
}

variable "core_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Core instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

# Task

variable "create_task_instance_group" {
  type        = bool
  description = "Whether to create an instance group for Task nodes. For more info: https://www.terraform.io/docs/providers/aws/r/emr_instance_group.html, https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html"
  default     = false
}

variable "task_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Task instance group"
  default     = null
}

variable "task_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Task instance group. Must be at least 1"
  default     = 1
}

variable "task_instance_group_ebs_size" {
  type        = number
  description = "Task instances volume size, in gibibytes (GiB)"
  default     = 10
}

variable "task_instance_group_ebs_optimized" {
  type        = bool
  description = "Indicates whether an Amazon EBS volume in the Task instance group is EBS-optimized. Changing this forces a new resource to be created"
  default     = false
}

variable "task_instance_group_ebs_type" {
  type        = string
  description = "Task instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "task_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Task volume supports"
  default     = null
}

variable "task_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Task instance group"
  default     = 1
}

variable "task_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Task instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

variable "extra_steps" {
  type = list(object({
    name              = string
    action_on_failure = string
    hadoop_jar_step = object({
      args       = list(string)
      jar        = string
      main_class = string
      properties = map(string)
    })
  }))
  description = "List of steps to run when creating the cluster. This cluster creates a step to setup hadoop debug logging by default. Any steps defined in this variable will be created as additional steps."
  default     = []
}

variable "bootstrap_actions" {
  type = list(object({
    name = string
    path = string
    args = list(string)
  }))
  description = "List of bootstrap actions that will be run before Hadoop is started on the cluster nodes"
  default     = []
}

# Core autoscaling policy

variable "create_core_instance_group_autoscaling_policy" {
  type        = bool
  description = "Whether to create an autoscaling policy for the core instance group."
  default     = false
}

variable "core_instance_group_minimum_capacity_units" {
  type        = number
  description = "Minimum capacity units for core instance group autoscaling policy."
  default     = null
}

variable "core_instance_group_maximum_capacity_units" {
  type        = number
  description = "Maximum capacity units for core instance group autoscaling policy."
  default     = null
}

variable "core_instance_group_minimum_ondemand_capacity_units" {
  type        = number
  description = "Minimum on demand capacity units for core instance group autoscaling policy."
  default     = null
}

variable "core_instance_group_maximum_core_capacity_units" {
  type        = number
  description = "Maximum core capacity units for core instance group autoscaling policy."
  default     = null
}

# Task autoscaling policy

variable "task_instance_group_autoscaling_policy" {
  type        = string
  description = "String containing the EMR Auto Scaling Policy JSON for the Task instance group"
  default     = null
}
