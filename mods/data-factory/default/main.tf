// zobacz to
// https://github.com/hmcts/terraform-module-azure-datafactory/blob/b822a74d484d3d15b3e9764e289cb3f08a6800c7/datafactory.tf

resource "azurerm_data_factory" "this" {
  location                        = var.location
  name                            = local.name
  purview_id                      = var.purview_id
  resource_group_name             = var.resource_group_name
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  public_network_enabled          = var.public_network_enabled

  # dynamic "identity" {
  #   for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
  #   content {
  #     type = var.identity_type
  #   }
  # }

  # dynamic "identity" {
  #   for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
  #   content {
  #     type         = var.identity_type
  #     identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
  #   }
  # }

  identity {
    type         = var.identity_type
    identity_ids = strcontains(var.identity_type, "UserAssigned") ? var.identity_ids : []
  }

  # dynamic "identity" {
  #   for_each = length(var.identity_ids) > 0 || var.identity_type == "SystemAssigned, UserAssigned" ? [var.identity_type] : []
  #   content {
  #     type         = var.identity_type
  #     identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
  #   }
  # }

  dynamic "global_parameter" {
    for_each = var.global_parameter != null ? var.global_parameter : []
    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }
  global_parameter {
    name  = "default_key_vault_uri"
    type  = "String"
    value = data.azurerm_key_vault.kivi.vault_uri
  }

  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []
    content {
      account_name       = github_configuration.value.account_name
      branch_name        = github_configuration.value.branch_name
      git_url            = github_configuration.value.git_url
      repository_name    = github_configuration.value.repository_name
      root_folder        = github_configuration.value.root_folder
      publishing_enabled = github_configuration.value.publishing_enabled
    }
  }
}

resource "azurerm_data_factory_credential_user_managed_identity" "default" {
  count           = local.umi_identity_id != null ? 1 : 0
  name            = local.umi_credential_name
  data_factory_id = azurerm_data_factory.this.id
  identity_id     = local.umi_identity_id
  depends_on      = [azurerm_data_factory.this]
}

# https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/linkedservices?pivots=deployment-language-arm-template#credentialreference-1

resource "azurerm_data_factory_linked_custom_service" "this" {
  for_each = { for inst in var.linked_custom_service : inst.name => inst if inst.deploy && strcontains(var.identity_type, "UserAssigned") }
  dynamic "integration_runtime" {
    for_each = each.value.integration_runtime[*]
    content {
      name       = each.value.integration_runtime
    }
  }
  name                 = each.value.name
  description          = each.value.description
  data_factory_id      = azurerm_data_factory.this.id
  type                 = each.value.type
  type_properties_json = each.value.type_properties_json
  parameters           = each.value.parameter
}


# resource "azurerm_data_factory_managed_private_endpoint" "keyvault" {
#   data_factory_id = azurerm_data_factory.this.id
#   target_resource_id = data.azurerm_key_vault.kivi.id //resource id is the ID of the Private Link resource
#   name = "data_factory_mpe_keyvault"
#   subresource_name = "vault"
#   fqdns = [join("", [data.azurerm_key_vault.kivi.name, ".vault.azure.net"])]
#   lifecycle {
#     # even if the folowing properties of the resource are not match with the template, it will not be updated. 
#     ignore_changes = [
#       fqdns,
#     ]
#   }
# }

# resource "azurerm_data_factory_linked_service_key_vault" "this" {
#   for_each = { for inst in var.lcs : inst.name => inst if inst.enabled && var.identity_type == "SystemAssigned" && inst.type == "AzureKeyVault"}
#   name = "${each.value.name}-ls-key-vault"
#   data_factory_id = azurerm_data_factory.this.id
#   key_vault_id = each.value.vault_uri
# }


# foreach passed MI create set of roles provided


/*

{
  principal_id = "",
  role = {
    scope = "kv", role_definition_name = "Key Vault Secrets User"
  },
  {
  scope = "kv", role_definition_name = "Storage Blob Data Contributor"
  }
}
*/


resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  # for_each = {
  #   for ir in local.integration_runtimes :
  #   ir.short_name => ir
  #   if ir.is_azure == false && var.deploy_data_factory == true
  # }
  # name                = each.value.name
  name = "SelfHostedRuntimeOnPrem"
  # data_factory_id     = azurerm_data_factory.data_factory[0].id
  data_factory_id = azurerm_data_factory.this.id

  #resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_data_factory.this
  ]
}





# resource "azurerm_data_factory_linked_custom_service" "mssqldatabase1" {
#   name            = "mssqldatabase1"
#   data_factory_id = azurerm_data_factory.this.id
#   type            = "SqlServer"
#   description     = "Generic SqlServer"
#   integration_runtime {
#     name = "SelfHostedRuntimeOnPrem"
#   }
#   type_properties_json = <<JSON
# {			
# 			"connectionString": "Integrated Security=True;Data Source=test\\dsk08;Initial Catalog=servername;User ID=username_db",
#       "password": {
# 				"type": "AzureKeyVaultSecret",
# 				"store": {
# 					"referenceName": "lcs-kv-ls-custom-service",
# 					"type": "LinkedServiceReference",
# 					"parameters": {
# 						"KeyVaultBaseUrl": {
# 							"value": "https://az-kv-dev-westeurope-001.vault.azure.net/",
# 							"type": "Expression"
# 						}
# 					}
# 				},
# 				"secretName": {
# 					"value": "passworddb",
# 					"type": "Expression"
# 				}
# 			}
# 		}
# JSON
#   parameters = {
#     Server          = "servername"
#     Database        = "test\\dsk08"
#     KeyVaultBaseUrl = "https://az-kv-dev-westeurope-001.vault.azure.net/"
#     PasswordSecret  = "password_db"
#     UserName        = "username_db"
#   }
# }

# resource "azurerm_data_factory_linked_custom_service" "azuredatabase1" {
#   name            = "azuredatabase1"
#   description     = "Generic Azure SQL Server"
#   type            = "AzureSqlDatabase"
#   data_factory_id = azurerm_data_factory.this.id
#   type_properties_json = <<JSON
#     {
# 			"connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=@{linkedService().Server};Initial Catalog=@{linkedService().Database}"
# 		}
# JSON
#   parameters = {
#     Server   = ""
#     Database = ""
#   }
# }


# resource "azurerm_data_factory_linked_custom_service" "mssqldatabase2" {
#   name            = "mssqldatabase2_params"
#   data_factory_id = azurerm_data_factory.this.id
#   type            = "SqlServer"
#   description     = "Generic SqlServer"
#   type_properties_json = <<JSON
# {			
# 			"connectionString": "Integrated Security=True;Data Source=@{linkedService().Server};Initial Catalog=@{linkedService().Database};User ID=@{linkedService().UserName}",
#       "password": {
# 				"type": "AzureKeyVaultSecret",
# 				"store": {
# 					"referenceName": "lcs-kv-ls-custom-service",
# 					"type": "LinkedServiceReference",
# 					"parameters": {
# 						"KeyVaultBaseUrl": {
# 							"value": "@linkedService().KeyVaultBaseUrl",
# 							"type": "Expression"
# 						}
# 					}
# 				},
# 				"secretName": {
# 					"value": "@linkedService().PasswordSecret",
# 					"type": "Expression"
# 				}
# 			}
# 		}
# JSON
#   parameters = {
#     Server          = "abs"
#     Database        = "cde"
#     KeyVaultBaseUrl = data.azurerm_key_vault.kivi.vault_uri
#     PasswordSecret  = "databasedb"
#     UserName        = "test"
#   }
# }


# resource "azurerm_data_factory_linked_custom_service" "dataverse" {
#   name            = "CommonDataServiceForApps-Dataverse"
#   data_factory_id = azurerm_data_factory.this.id
#   type            = "CommonDataServiceForApps"
#   description     = "Generic CommonDataServiceForApps"
#   type_properties_json = <<JSON
# {			
# 			"deploymentType": "Online",
#       "serviceUri" : "https://google.crm4.com",
#      "authenticationType": "ManagedIdentity"
#     }
# JSON
#   parameters = {
#     Server          = "abs"
#     Database        = "cde"
#     KeyVaultBaseUrl = data.azurerm_key_vault.kivi.vault_uri
#     PasswordSecret  = "databasedb"
#     UserName        = "test"
#   }
# }