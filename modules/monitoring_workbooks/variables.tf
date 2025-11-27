variable "resource_group_name" {
  type        = string
  description = "Nom du resource group où le workbook sera créé"
}

variable "location" {
  type        = string
  description = "Région Azure du workbook (souvent la même que le workspace)"
}

variable "workspace_id" {
  type        = string
  description = "Resource ID du Log Analytics Workspace cible"
}

variable "workbook_display_name" {
  type        = string
  description = "Nom affiché du workbook dans le portail Azure"
}

variable "workbook_json_path" {
  type        = string
  description = "Chemin vers le fichier JSON du workbook"
}
