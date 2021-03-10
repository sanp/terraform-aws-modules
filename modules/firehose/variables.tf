variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name of the firehose delivery stream."
}

variable "sink_bucket_arn" {
  type        = string
  description = "Name of the sink bucket"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of transform lambda"
}

##
# Config Variables
##

variable "firehose_destination" {
  type        = string
  description = "Firehose destination"
  default     = "extended_s3"
}

variable "processing_enabled" {
  type        = string
  description = "Flag to indicate if processor is enabled"
  default     = "true"
}

variable "processing_type" {
  type        = string
  description = "Type of processor"
  default     = "Lambda"
}

variable "processor_parameter_name" {
  type        = string
  description = "Processor ARN"
  default     = "LambdaArn"
}

variable "policy_version" {
  type        = string
  description = "Policy Version"
  default     = "2012-10-17"
}

variable "sse_enabled" {
  type        = bool
  description = "Flag to indicate if SSE is enabled"
  default     = true
}

variable "cmk_type" {
  type    = string
  description = "CMK type"
  default = "AWS_OWNED_CMK"
}

variable "key_arn" {
  type        = string
  description = "SSE Key ARN, only required when cmk_type is CUSTOMER_MANAGED_CMK"
  default     = ""
}

variable "buffer_size" {
  type    = number
  description = "Firehose Buffer size "
  default = 128
}
