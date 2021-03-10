variable "base_tags" {
  type        = map(string)
  description = "Base tags to be used."
}

variable "table_name" {
  type        = string
  description = "Name of the dynamo table to create."
}

variable "table_key" {
  type        = string
  description = "Name of the hash key column in Dynamo table."
}

variable "table_items" {
  type        = map(string)
  description = "Items to write to table."
}

##
# Variables with default values.
##

variable "billing_mode" {
  type    = string
  default = "PROVISIONED"
}

variable "read_capacity" {
  type    = number
  default = 20
}

variable "write_capacity" {
  type    = number
  default = 20
}

variable "table_key_type" {
  type    = string
  default = "S"
}
