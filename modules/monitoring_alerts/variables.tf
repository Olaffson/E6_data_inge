variable "resource_group_name" {
  type        = string
  description = "Resource group contenant les ressources de monitoring"
}

variable "location" {
  type        = string
  description = "Région Azure"
}

variable "workspace_id" {
  type        = string
  description = "Resource ID du Log Analytics Workspace (doit être /subscriptions/.../Microsoft.OperationalInsights/workspaces/...)"
}

variable "alert_email" {
  type        = string
  description = "Email de réception des alertes"
}

variable "asa_job_name" {
  type        = string
  description = "Nom du job Stream Analytics (ex: asa-shopnow)"
  default     = "asa-shopnow"
}

# Seuils (customisables)
variable "eventhub_incoming_min_threshold" {
  type        = number
  description = "Seuil minimal de messages entrants sur la fenêtre (alerte si < seuil)"
  default     = 1
}

variable "asa_error_threshold" {
  type        = number
  description = "Seuil d'erreurs ASA (alerte si > seuil)"
  default     = 0
}

variable "sql_cpu_threshold" {
  type        = number
  description = "Seuil CPU SQL (%) (alerte si > seuil)"
  default     = 80
}

variable "tags" {
  type        = map(string)
  description = "Tags à appliquer aux ressources"
  default     = {}
}
