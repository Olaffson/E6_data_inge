variable "resource_group_name" {
  type        = string
  description = "Resource group où créer les alertes"
}

variable "location" {
  type        = string
  description = "Région Azure des alertes"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID du Log Analytics Workspace"
}

variable "alert_email" {
  type        = string
  description = "Adresse e-mail qui recevra les alertes"
}
