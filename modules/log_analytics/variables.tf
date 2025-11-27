variable "resource_group_name" {
  description = "Nom du resource group"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
}

variable "workspace_name" {
  description = "Nom du Log Analytics Workspace"
  type        = string
}
