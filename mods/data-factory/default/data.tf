data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "umi" {
  name = local.umi_name
  resource_group_name = var.resource_group_name
}


data "azurerm_key_vault" "kivi" {
  name = var.default_kv_name
  resource_group_name = var.resource_group_name
}