variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name of lambda to be created by this module."
}

variable "description" {
  type        = string
  description = "Description of lambda to be created by this module."
}

variable "env_variables" {
  type        = map(string)
  description = "Environment variables to provide to this lambda function."
  default     = {}
}

variable "git_repo" {
  type        = string
  description = "Git repository for the lambda code."
}

##
# VPC Variables
##

variable "configure_vpc" {
  type        = bool
  description = "If true, this lambda will create a security group and configure the lambda to access a VPC. If true, a vpc_id must be provided. If false, no VPC will be configured and no security group will be created."
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to add to VPC configuration. Only supply values if has_vpc_config is true."
  default     = []
}

##
# Source code variables
##

variable "empty" {
  type        = bool
  description = "If true, this module will create an empty lambda. If false, you must provide a lambda file location which will be uploaded."
  default     = false
}

variable "source_is_s3" {
  type        = bool
  description = "If true, the source code for this lambda is stored in S3. Do not set to true if empty is true."
  default     = false
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket containing source code package. Only set this variable if empty is false and source_is_s3 is true."
  default     = null
}

variable "s3_key" {
  type        = string
  description = "S3 key containing source code package. Only set this variable if empty is false and source_is_s3 is true."
  default     = null
}

variable "source_is_file" {
  type        = bool
  description = "If true, the source for this lambda is a file. Else, the source is a directory. Only set this variable if empty is false."
  default     = false
}

variable "source_path" {
  type        = string
  description = "Path to source file or source directory. Only set this variable if empty is false."
  default     = null
}

##
# Config Variables
##

variable "runtime" {
  type        = string
  description = "Runtime to use for lambda."
  default     = "python3.8"
}

variable "archive_type" {
  type        = string
  description = "File type of the archive containing lambda code."
  default     = "zip"
}

variable "empty_filename" {
  type        = string
  description = "The name of the empty code file to produce if var.empty is set to true."
  default     = "index.py"
}

variable "handler" {
  type        = string
  description = "The handler function entrypoint for the lambda."
  default     = "index.handler"
}

variable "memory_size" {
  type        = number
  description = "Amount of memory (mb) to alot to lambda."
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Amount of time lambda function has to run in seconds."
  default     = 60
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  default     = -1
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which KMS key is deleted after destruction of resource. Between 7 and 30."
  default     = 7
}

variable "sg_revoke_rules_on_delete" {
  type        = bool
  description = "Instruct Terraform to revoke all of the Security Groups attached ingress and egress rules before deleting the rule itself."
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

##
# Dead letter queue variables
##

variable "create_dead_letter_queue" {
  type        = bool
  description = "Whether or not to create a dead letter queue for this lambda."
  default     = false
}

variable "dlq_delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)."
  default     = 0
}

variable "dlq_max_message_size" {
  type        = number
  description = "Max message size in bytes of SQS messages. 1024 to 262144."
  default     = 262144
}

variable "dlq_message_retention_seconds" {
  type        = number
  description = "Number of seconds SQS retains message. 60 to 1209600."
  default     = 1209600
}

variable "dlq_receive_wait_time_seconds" {
  type        = number
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)."
  default     = 20
}
