variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_admin_login" {
  type = string
}

variable "sql_admin_password" {
  type = string
}

variable "schema_file_path" {
  type        = string
  description = "Path to the SQL schema file"
}

variable "sql_short_term_retention_days" {
  description = "Nombre de jours de rétention pour le Point-In-Time Restore (7 à 35)."
  type        = number
  default     = 14
}

variable "sql_ltr_weekly_retention" {
  description = "Durée de rétention hebdomadaire des backups LTR (ISO 8601, ex: P4W)."
  type        = string
  default     = "P4W"
}

variable "sql_ltr_monthly_retention" {
  description = "Durée de rétention mensuelle des backups LTR (ISO 8601, ex: P12M)."
  type        = string
  default     = "P12M"
}

variable "sql_ltr_yearly_retention" {
  description = "Durée de rétention annuelle des backups LTR (ISO 8601, ex: P10Y)."
  type        = string
  default     = "P10Y"
}

variable "sql_ltr_week_of_year" {
  description = "Semaine de l'année pour le backup annuel (1 à 52)."
  type        = number
  default     = 1
}
