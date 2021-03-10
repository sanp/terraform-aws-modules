variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name to be used for SNS topic."
}

variable "s3_bucket" {
  type        = string
  description = "Name of the S3 bucket which the SNS topic will be subscribed to."
}

##
# Variables with default values.
##

variable "policy_version" {
  type        = string
  description = "AWS policy language version. The latest is 2012-10-17."
  default     = "2012-10-17"
}
