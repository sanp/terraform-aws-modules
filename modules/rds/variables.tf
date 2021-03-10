variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "name" {
  type        = string
  description = "Name to be used for database."
}

variable "id" {
  type        = string
  description = "ID to be used for database."
}

variable "username" {
  type        = string
  description = "Username for the master user."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the DB security group."
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of the DB subnet group."
}

##
# Variables with default values.
##

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in gb."
  default     = 100
}

variable "port" {
  type        = number
  description = "Port for database."
  default     = 5432
}

variable "instance_class" {
  type        = string
  description = "Instance type of the RDS instance."
  default     = "db.m4.large"
}

variable "password_length" {
  type        = number
  description = "Character length of passwords."
  default     = 12
}

variable "kms_deletion_window_in_days" {
  type    = number
  default = 7
}

variable "sg_revoke_rules_on_delete" {
  type    = bool
  default = true
}

variable "allow_major_version_upgrade" {
  type    = bool
  default = true
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "iam_database_authentication_enabled" {
  type    = bool
  default = true
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "12.4"
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "performance_insights_enabled" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}
