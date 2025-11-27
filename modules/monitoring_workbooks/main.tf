locals {
  # On lit le JSON tel quel depuis le fichier (ton workbook_e6_monitoring.json)
  workbook_content = file(var.workbook_json_path)
}

resource "azurerm_application_insights_workbook" "e6_workbook" {
  # Le nom d’un workbook doit être un GUID (recommandé par Microsoft).
  # uuidv5 donne un GUID stable basé sur workspace_id + nom => pas besoin de provider random.
  name                = uuidv5("dns", "${var.workspace_id}-${var.workbook_display_name}")
  resource_group_name = var.resource_group_name
  location            = var.location

  display_name = var.workbook_display_name
  # Très important : on cible ton Log Analytics Workspace
  source_id    = lower(var.workspace_id)
  category     = "workbook"

  # Le JSON complet du workbook (version, items, etc.)
  data_json = local.workbook_content
}
