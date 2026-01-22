variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_server_fqdn" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_admin_login" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "full_backup_retention_days" {
  type    = number
  default = 30
}

variable "partial_backup_retention_days" {
  type    = number
  default = 14
}

variable "schedule_timezone" {
  type    = string
  default = "UTC"
}

variable "purge_clickstream_retention_days" {
  type    = number
  default = 90
}
