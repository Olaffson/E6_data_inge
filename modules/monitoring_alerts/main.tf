resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-e6-ops"
  resource_group_name = var.resource_group_name
  short_name          = "e6ops"

  email_receiver {
    name          = "ops-email"
    email_address = var.alert_email
  }
}

#
# Alerte 1 – Erreurs Stream Analytics (asa-shopnow)
#
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "asa_errors" {
  name                = "alert-asa-shopnow-errors"
  resource_group_name = var.resource_group_name
  location            = var.location

  display_name        = "Stream Analytics - Erreurs asa-shopnow"
  description         = "Alerte si le job Stream Analytics asa-shopnow génère des erreurs."
  severity            = 2                    # 0 = Critical, 4 = Verbose
  evaluation_frequency = "PT5M"              # toutes les 5 minutes
  window_duration      = "PT5M"              # fenêtre d'analyse = 5 minutes
  enabled             = true

  scopes = [
    var.log_analytics_workspace_id
  ]

  criteria {
    query = <<KQL
AzureDiagnostics
| where ResourceType == "STREAMINGJOBS"
| where Resource has "asa-shopnow"
| where Level == "Error"
KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }
}

#
# Alerte 2 – Aucun message Event Hub depuis 10 minutes
#
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "eventhub_no_messages" {
  name                = "alert-eventhub-no-messages"
  resource_group_name = var.resource_group_name
  location            = var.location

  display_name        = "Event Hubs - Aucun message orders"
  description         = "Alerte si le namespace Event Hub ne reçoit aucun message pendant 10 minutes."
  severity            = 3
  evaluation_frequency = "PT10M"
  window_duration      = "PT10M"
  enabled             = true

  scopes = [
    var.log_analytics_workspace_id
  ]

  criteria {
    query = <<KQL
AzureMetrics
| where ResourceId has "MICROSOFT.EVENTHUB/NAMESPACES"
| where MetricName == "IncomingMessages"
| summarize TotalMessages = sum(Total) by bin(TimeGenerated, 10m)
| where TotalMessages == 0
KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }
}

#
# Alerte 3 – CPU SQL trop élevé
#
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "sql_high_cpu" {
  name                = "alert-sql-high-cpu"
  resource_group_name = var.resource_group_name
  location            = var.location

  display_name        = "SQL DWH - CPU élevé"
  description         = "Alerte si le CPU du serveur SQL dépasse 80% pendant au moins 5 minutes."
  severity            = 3
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  enabled             = true

  scopes = [
    var.log_analytics_workspace_id
  ]

  criteria {
    query = <<KQL
AzureMetrics
| where ResourceId has "MICROSOFT.SQL/SERVERS"
| where MetricName == "cpu_percent"
| summarize AvgCpu = avg(Average) by bin(TimeGenerated, 5m)
| where AvgCpu > 80
KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ops.id]
  }
}
