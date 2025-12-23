resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-e6-ops"
  resource_group_name = var.resource_group_name
  short_name          = "e6ops"

  email_receiver {
    name          = "ops-email"
    email_address = var.alert_email
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "eventhub_no_messages" {
  name                = "alert-eventhub-no-messages"
  resource_group_name = var.resource_group_name
  location            = var.location
  scopes              = [var.workspace_id]

  description          = "Alerte si Event Hubs ne reçoit presque aucun message."
  enabled              = true
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<KQL
AzureMetrics
| where ResourceId has "microsoft.eventhub/namespaces"
| where MetricName == "IncomingMessages"
| summarize Value = sum(Total)
KQL

    time_aggregation_method = "Total"
    operator                = "LessThan"
    threshold               = var.eventhub_incoming_min_threshold
    metric_measure_column   = "Value"

    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "asa_errors" {
  name                = "alert-asa-shopnow-errors"
  resource_group_name = var.resource_group_name
  location            = var.location
  scopes              = [var.workspace_id]

  description          = "Alerte si Stream Analytics génère des erreurs."
  enabled              = true
  severity             = 1
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<KQL
AzureDiagnostics
| where ResourceType == "STREAMINGJOBS"
| where Resource has "${var.asa_job_name}"
| where Level == "Error"
| summarize Value = count()
KQL

    time_aggregation_method = "Total"
    operator                = "GreaterThan"
    threshold               = var.asa_error_threshold
    metric_measure_column   = "Value"

    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sql_high_cpu" {
  name                = "alert-sql-high-cpu"
  resource_group_name = var.resource_group_name
  location            = var.location
  scopes              = [var.workspace_id]

  description          = "Alerte si le CPU SQL dépasse le seuil défini."
  enabled              = true
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<KQL
AzureMetrics
| where ResourceId has "microsoft.sql/servers"
| where MetricName == "cpu_percent"
| summarize Value = avg(Average)
KQL

    time_aggregation_method = "Average"
    operator                = "GreaterThan"
    threshold               = var.sql_cpu_threshold
    metric_measure_column   = "Value"

    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }

  tags = var.tags
}
