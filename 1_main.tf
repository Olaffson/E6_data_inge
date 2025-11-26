resource "azurerm_resource_group" "rg" {
  name     = "rg-e6-${var.username}"
  location = var.location
}

// Event Hubs
module "module_event_hubs" {
  source                  = "./modules/event_hubs"
  depends_on              = [azurerm_resource_group.rg]
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  eventhub_namespace_name = "eh-${var.username}"
  eventhubs               = var.eventhubs
}

// DB
module "sql_database" {
  source              = "./modules/sql_database"
  depends_on          = [module.module_event_hubs]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sql_admin_login     = var.sql_admin_login
  sql_admin_password  = var.sql_admin_password
  schema_file_path    = "${path.root}/dwh_schema.sql"

  # Backups
  sql_short_term_retention_days = 14

  # LTR
  sql_ltr_weekly_retention  = "P4W"
  sql_ltr_monthly_retention = "P12M"
  sql_ltr_yearly_retention  = "P10Y"
  sql_ltr_week_of_year      = 1
}

// Stream
module "stream_analytics" {
  source                     = "./modules/stream_analytics"
  depends_on                 = [module.module_event_hubs, module.sql_database]
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  eventhub_namespace_name    = "eh-${var.username}"
  eventhub_listen_key        = module.module_event_hubs.listen_connection_string
  sql_server_fqdn            = module.sql_database.server_fqdn
  sql_database_name          = module.sql_database.database_name
  sql_admin_login            = var.sql_admin_login
  sql_admin_password         = var.sql_admin_password
}

// Event Producers
module "container_producers" {
  source     = "./modules/container_producers"
  depends_on = [module.module_event_hubs, module.stream_analytics]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  container_image   = var.container_producers_image
  connection_string = module.module_event_hubs.send_connection_string

  dockerhub_username = var.dockerhub_username
  dockerhub_token    = var.dockerhub_token
}

// Log Analytics
module "log_analytics" {
  source = "./modules/log_analytics"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace_name      = "law-e6-${var.username}"
}

// Monitoring Alerts
module "monitoring_alerts" {
  source = "./modules/monitoring_alerts"

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  alert_email = "olivierkotwica@gmail.com"
}
