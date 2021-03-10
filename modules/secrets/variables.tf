variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used on bucket. Tags will also include bucket name."
}

variable "secret_name" {
  type        = string
  description = "Name of secret to be created by this module."
}

variable "secret_description" {
  type        = string
  description = "Description of secret to be created by this module."
}

variable "secret" {
  type        = map(string)
  description = "Secret to be stored, as a key value map."
}

##
# Variables with defaults
##

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days AWS waits before it can delete the resource. Set to 0 so that you can create and destroy resources immediately with terraform."
  default     = 0
}

variable "deletion_window_in_days" {
  type        = number
  description = "Duration in days after which key is deleted after destruction of resource. Between 7 and 30."
  default     = 7
}
