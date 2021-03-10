variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name to be used for SQS queue."
}

variable "sns_topic" {
  type        = string
  description = "ARN of the SNS topic which this queue will be subscribed to."
}

variable "lambda" {
  type        = string
  description = "ARN of the lambda which this SQS queue will trigger."
}

##
# Variables with default values.
##

variable "policy_version" {
  type        = string
  description = "AWS policy language version. The latest is 2012-10-17."
  default     = "2012-10-17"
}

variable "delay_seconds" {
  type        = number
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)."
  default     = 0
}

variable "max_message_size" {
  type        = number
  description = "Max message size in bytes of SQS messages. 1024 to 262144."
  default     = 262144
}

variable "message_retention_seconds" {
  type        = number
  description = "Number of seconds SQS retains message. 60 to 1209600."
  default     = 1209600
}

variable "receive_wait_time_seconds" {
  type        = number
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)."
  default     = 20
}

variable "max_recieve_count" {
  type        = number
  description = "Maximum number of times a message will be attempted for processing before being redrived to the dead letter queue."
  default     = 5
}

variable "lambda_batch_size" {
  type        = number
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invocation."
  default     = 1
}
