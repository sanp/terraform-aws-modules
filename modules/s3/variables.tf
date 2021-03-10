variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used on bucket. Tags will also include bucket name."
}

variable "bucket_name" {
  type        = string
  description = "Name of bucket to be created by this module."
}

variable "upload_files" {
  type = list(object({
    s3_key    = string
    file_path = string
  }))
  description = "List of files to upload to S3 bucket. If empty, no files will be uploaded."
  default     = []
}

##
# Variables with default values.
##

variable "acl" {
  type    = string
  default = "private"
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "sse_algorithm" {
  type    = string
  default = "AES256"
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

##
# Object locking variables
##

variable "object_lock_enabled" {
  type        = bool
  description = "Whether to enable object locking on this bucket. If true, then the object_lock_configuration dynamic block will be created."
  default     = true
}

variable "object_lock_legal_hold_status" {
  type        = string
  description = "The legal hold status that you want to apply to the specified object."
  default     = null
  validation {
    # The try falls back to true here in order to allow this variable to be
    # null. If it is not null, then it must be one of the values in the
    # `contains` block.
    condition = try(
      contains(["ON", "OFF"], var.object_lock_legal_hold_status), true
    )
    error_message = "If set, valid values of object_lock_legal_hold_status are ON and OFF."
  }
}

variable "object_lock_mode" {
  type        = string
  description = "The object lock retention mode that you want to apply to this object. Valid values are GOVERNANCE and COMPLIANCE."
  default     = null
  validation {
    # The try falls back to true here in order to allow this variable to be
    # null. If it is not null, then it must be one of the values in the
    # `contains` block.
    condition = try(
      contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode), true
    )
    error_message = "If set, valid values of object_lock_mode are GOVERNANCE and COMPLIANCE."
  }
}

variable "object_lock_retain_until_date" {
  type        = string
  description = "The date and time, in RFC3339 format, when this object's object lock will expire."
  default     = null
}
