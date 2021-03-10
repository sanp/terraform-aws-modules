variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "domain_name" {
  type        = string
  description = "Name of the domain to create."
}

variable "repository_name" {
  type        = string
  description = "Name of the repository to create."
}

variable "external_upstream_connection" {
  type        = string
  description = "Name of the external upstream connection."
  validation {
    condition     = contains(["pypi", "npmjs", "maven-central", "maven-googleandroid", "maven-gradleplugins", "maven-commonsware"], var.external_upstream_connection)
    error_message = "The external_upstream_connection is not valid."
  }
}

variable "domain_policy" {
  type        = string
  description = "Policy document to apply to the domain."
}

variable "repository_policy" {
  type        = string
  description = "Policy document to apply to the repository."
}

##
# Variables with default values.
##

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which KMS key is deleted after destruction of resource. Between 7 and 30."
  default     = 7
}
