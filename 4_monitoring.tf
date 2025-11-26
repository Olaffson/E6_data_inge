# Diagnostics SQL DWH
resource "azurerm_monitor_diagnostic_setting" "sql_dwh_diagnostics" {
  name                       = "diag-sqldb-dwh"
  target_resource_id         = module.sql_database.database_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostics Stream Analytics Job
resource "azurerm_monitor_diagnostic_setting" "asa_job_diagnostics" {
  name                       = "diag-asa-job"
  target_resource_id         = module.stream_analytics.job_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "Execution"
  }

  enabled_log {
    category = "Authoring"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostics Event Hub Namespace (optionnel mais recommandé)
resource "azurerm_monitor_diagnostic_setting" "eh_namespace_diagnostics" {
  name                       = "diag-eh-namespace"
  target_resource_id         = module.module_event_hubs.namespace_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
