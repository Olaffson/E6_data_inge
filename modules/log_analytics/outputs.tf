output "workspace_id" {
  description = "ID (resource ID) du workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Nom du workspace"
  value       = azurerm_log_analytics_workspace.this.name
}
