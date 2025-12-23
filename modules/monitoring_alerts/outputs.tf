output "action_group_id" {
  value       = azurerm_monitor_action_group.ops.id
  description = "ID du Action Group utilisé pour les alertes"
}

output "alerts" {
  description = "IDs des alertes créées"
  value = {
    eventhub_no_messages = azurerm_monitor_scheduled_query_rules_alert_v2.eventhub_no_messages.id
    asa_errors           = azurerm_monitor_scheduled_query_rules_alert_v2.asa_errors.id
    sql_high_cpu         = azurerm_monitor_scheduled_query_rules_alert_v2.sql_high_cpu.id
  }
}
