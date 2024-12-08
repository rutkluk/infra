data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "umi" {
  name = local.umi_name
  resource_group_name = var.resource_group_name
}

// try(regex("[^/]+$", local.umi_identity_id))

data "azurerm_key_vault" "kivi" {
  name = try(regex("[^/]+$", var.default_kv_id))
  resource_group_name = var.resource_group_name
}