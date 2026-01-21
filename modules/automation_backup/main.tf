resource "azurerm_automation_account" "backup" {
  name                = "aa-backup-${lower(replace(var.resource_group_name, \"_\", \"-\"))}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
}

resource "azurerm_automation_module" "sqlserver" {
  name                    = "SqlServer"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/SqlServer"
  }
}

resource "azurerm_automation_credential" "sql_admin" {
  name                    = "SqlAdmin"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  username                = var.sql_admin_login
  password                = var.sql_admin_password
}

resource "azurerm_automation_variable_string" "sql_server_fqdn" {
  name                    = "SqlServerFqdn"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  value                   = var.sql_server_fqdn
}

resource "azurerm_automation_variable_string" "sql_database_name" {
  name                    = "SqlDatabaseName"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  value                   = var.sql_database_name
}

resource "azurerm_automation_variable_string" "full_backup_retention_days" {
  name                    = "FullBackupRetentionDays"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  value                   = tostring(var.full_backup_retention_days)
}

resource "azurerm_automation_variable_string" "partial_backup_retention_days" {
  name                    = "PartialBackupRetentionDays"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  value                   = tostring(var.partial_backup_retention_days)
}

resource "azurerm_automation_runbook" "full_backup" {
  name                    = "rb-full-backup"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  log_progress            = true
  log_verbose             = true
  runbook_type            = "PowerShell"

  content = <<-PS1
    Import-Module SqlServer

    $server = Get-AutomationVariable -Name "SqlServerFqdn"
    $db = Get-AutomationVariable -Name "SqlDatabaseName"
    $retentionDays = [int](Get-AutomationVariable -Name "FullBackupRetentionDays")
    $cred = Get-AutomationPSCredential -Name "SqlAdmin"

    $suffix = (Get-Date).ToUniversalTime().ToString("yyyyMMdd")
    $backupDb = "${db}_full_${suffix}"

    $createQuery = "IF DB_ID('$backupDb') IS NULL CREATE DATABASE [$backupDb] AS COPY OF [$db];"
    Invoke-Sqlcmd -ServerInstance $server -Database "master" -Credential $cred -Query $createQuery

    $cutoff = (Get-Date).ToUniversalTime().AddDays(-$retentionDays).ToString("yyyyMMdd")
    $cleanupQuery = @"
DECLARE @cutoff VARCHAR(8) = '$cutoff';
DECLARE @db SYSNAME = '$db';
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'DROP DATABASE [' + name + '];'
FROM sys.databases
WHERE name LIKE @db + '_full_%' AND RIGHT(name, 8) < @cutoff;
IF LEN(@sql) > 0 EXEC sp_executesql @sql;
"@
    Invoke-Sqlcmd -ServerInstance $server -Database "master" -Credential $cred -Query $cleanupQuery
  PS1

  depends_on = [azurerm_automation_module.sqlserver]
}

resource "azurerm_automation_runbook" "partial_backup" {
  name                    = "rb-partial-backup"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  log_progress            = true
  log_verbose             = true
  runbook_type            = "PowerShell"

  content = <<-PS1
    Import-Module SqlServer

    $server = Get-AutomationVariable -Name "SqlServerFqdn"
    $db = Get-AutomationVariable -Name "SqlDatabaseName"
    $retentionDays = [int](Get-AutomationVariable -Name "PartialBackupRetentionDays")
    $cred = Get-AutomationPSCredential -Name "SqlAdmin"

    $suffix = (Get-Date).ToUniversalTime().ToString("yyyyMMdd")
    $schema = "backup"

    $tables = @("fact_order", "dim_seller", "dim_product")

    $setupQuery = "IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = '$schema') EXEC('CREATE SCHEMA $schema');"
    Invoke-Sqlcmd -ServerInstance $server -Database $db -Credential $cred -Query $setupQuery

    foreach ($t in $tables) {
      $backupTable = "${schema}.${t}_${suffix}"
      $query = @"
IF OBJECT_ID('$backupTable', 'U') IS NOT NULL DROP TABLE $backupTable;
SELECT * INTO $backupTable FROM dbo.$t;
"@
      Invoke-Sqlcmd -ServerInstance $server -Database $db -Credential $cred -Query $query

      $cutoff = (Get-Date).ToUniversalTime().AddDays(-$retentionDays).ToString("yyyyMMdd")
      $cleanupQuery = @"
DECLARE @cutoff VARCHAR(8) = '$cutoff';
DECLARE @schema SYSNAME = '$schema';
DECLARE @prefix SYSNAME = '${t}_';
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'DROP TABLE [' + @schema + '].[' + t.name + '];'
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = @schema AND t.name LIKE @prefix + '%' AND RIGHT(t.name, 8) < @cutoff;
IF LEN(@sql) > 0 EXEC sp_executesql @sql;
"@
      Invoke-Sqlcmd -ServerInstance $server -Database $db -Credential $cred -Query $cleanupQuery
    }
  PS1

  depends_on = [azurerm_automation_module.sqlserver]
}

resource "azurerm_automation_schedule" "full_backup" {
  name                    = "sched-full-backup"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  frequency               = "Week"
  interval                = 1
  timezone                = var.schedule_timezone
  start_time              = timeadd(timestamp(), "1h")

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_schedule" "partial_backup" {
  name                    = "sched-partial-backup"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.backup.name
  frequency               = "Day"
  interval                = 1
  timezone                = var.schedule_timezone
  start_time              = timeadd(timestamp(), "1h")

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_job_schedule" "full_backup" {
  automation_account_name = azurerm_automation_account.backup.name
  resource_group_name     = var.resource_group_name
  runbook_name            = azurerm_automation_runbook.full_backup.name
  schedule_name           = azurerm_automation_schedule.full_backup.name
}

resource "azurerm_automation_job_schedule" "partial_backup" {
  automation_account_name = azurerm_automation_account.backup.name
  resource_group_name     = var.resource_group_name
  runbook_name            = azurerm_automation_runbook.partial_backup.name
  schedule_name           = azurerm_automation_schedule.partial_backup.name
}
