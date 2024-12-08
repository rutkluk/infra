resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "tfstate${random_string.resource_code.result}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "tfstate"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

variable "env" {
  type    = string
  default = "dev"
}

resource "azurerm_resource_group" "this" {
  name     = "app"
  location = "westeurope"
}

resource "azurerm_network_security_group" "this" {
  name                = "az-nsg-dev-westeurope-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_virtual_network" "this" {
  name                = "az-vnet-dev-westeurope-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.1.0/24"]

  subnet {
    name             = "az-subnet-westeurope-001"
    address_prefixes = ["10.0.1.0/27"]
    security_group   = azurerm_network_security_group.this.id
  }

  subnet {
    name             = "az-subnet-westeurope-002"
    address_prefixes = ["10.0.1.32/27"]
    security_group   = azurerm_network_security_group.this.id
  }

  tags = {
    environment = var.env
  }
}

data "azurerm_client_config" "current" {}

# # create general kv
# # ---------------------------------
resource "azurerm_key_vault" "kv" {
  name                        = "az-kv-dev-westeurope-001"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}


# resource "azurerm_user_assigned_identity" "factory-umid" {
#   name                = "adf_umid"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = "North Europe"
# }


# resource "azurerm_data_factory" "this" {
#   name                   = "az-adf-dev-westeurope-001"
#   location               = azurerm_resource_group.this.location
#   resource_group_name    = azurerm_resource_group.this.name
#   public_network_enabled = false
#   identity {
#     type = "SystemAssigned, UserAssigned"
#     identity_ids = [
#       azurerm_user_assigned_identity.factory-umid.id
#     ]
#   }
#   depends_on = [azurerm_user_assigned_identity.factory-umid]
# }


# resource "azurerm_data_factory_credential_user_managed_identity" "default" {
#   name            = "cred-default"
#   data_factory_id = azurerm_data_factory.this.id
#   identity_id     = azurerm_user_assigned_identity.factory-umid.id
#   depends_on      = [azurerm_data_factory.this]
# }


# resource "azurerm_storage_account" "storage" {
#   name                     = "adf7612"
#   resource_group_name      = azurerm_resource_group.this.name
#   location                 = "North Europe"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# data "azurerm_client_config" "current" {}


# resource "azurerm_key_vault" "kv_adf" {
#   name                          = "kvadf7651"
#   resource_group_name           = azurerm_resource_group.this.name
#   location                      = azurerm_resource_group.this.location
#   tenant_id                     = data.azurerm_client_config.current.tenant_id
#   sku_name                      = "premium"
#   enable_rbac_authorization     = true
#   public_network_access_enabled = true
# }

# resource "azurerm_role_assignment" "umid-sta-contr" {
#   scope                = azurerm_storage_account.storage.id
#   principal_id         = azurerm_user_assigned_identity.factory-umid.principal_id
#   role_definition_name = "Storage Blob Data Contributor"
# }

# resource "azurerm_role_assignment" "umid-kv-user" {
#   scope                = azurerm_key_vault.kv_adf.id
#   principal_id         = azurerm_user_assigned_identity.factory-umid.principal_id
#   role_definition_name = "Key Vault Secrets User"
# }

# resource "azurerm_data_factory_linked_custom_service" "ls-akv" {
#   name            = "LS_AKEV_terrademoneu"
#   data_factory_id = azurerm_data_factory.this.id
#   type            = "AzureKeyVault"
#   type_properties_json = jsonencode(
#     {
#       "baseUrl" : "${azurerm_key_vault.kv_adf.vault_uri}",
#       "credential" : {
#         "referenceName" : "${azurerm_data_factory_credential_user_managed_identity.default.name}",
#         "type" : "CredentialReference"
#       }
#     }
#   )
#   depends_on = [azurerm_role_assignment.umid-kv-user]
# }
# resource "azurerm_data_factory_linked_custom_service" "ls-sta" {
#   name            = "LS_ADLS_terrademoneu"
#   data_factory_id = azurerm_data_factory.this.id
#   type            = "AzureBlobFS"
#   type_properties_json = jsonencode(
#     {
#       "url" : "${azurerm_storage_account.storage.primary_dfs_endpoint}",
#       "credential" : {
#         "referenceName" : "${azurerm_data_factory_credential_user_managed_identity.default.name}",
#         "type" : "CredentialReference"
#       }
#     }
#   )
#   depends_on = [azurerm_role_assignment.umid-sta-contr]
# }

# resource "azurerm_data_factory_integration_runtime_self_hosted" "shir" {
#   name            = "shir-terra-demo"
#   data_factory_id = azurerm_data_factory.this.id
#   depends_on      = [azurerm_data_factory.this]
# }

module "uami" {
  source              = "./mods/uami/default"
  name                = "id5617"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  scopes = {
    1 = {
    scope     = azurerm_key_vault.kv.id
    role_name = "Key Vault Secrets User"
    }
    2 = {
      scope     = azurerm_key_vault.kv.id
      role_name = "Key Vault Crypto User"
    }
    3 = {
      scope     = azurerm_key_vault.kv.id
      role_name = "Key Vault Certificate User"
  }}
}

# resource "azurerm_role_assignment" "umid-key-vault-secrets-user" {
#   scope                = azurerm_key_vault.kv.id
#   principal_id         = module.uami.identity_principal_id
#   role_definition_name = "Key Vault Secrets User"
# }
# resource "azurerm_role_assignment" "umid-key-vault-crypto-user" {
#   scope                = azurerm_key_vault.kv.id
#   principal_id         = module.uami.identity_principal_id
#   role_definition_name = "Key Vault Crypto User"
# }
# resource "azurerm_role_assignment" "umid-key-vault-certificate-user" {
#   scope                = azurerm_key_vault.kv.id
#   principal_id         = module.uami.identity_principal_id
#   role_definition_name = "Key Vault Certificate User"
# }


module "adf" {
  source                = "./mods/data-factory/default"
  resource_group_name   = azurerm_resource_group.this.name
  identity_type         = "SystemAssigned, UserAssigned"
  identity_ids          = [module.uami.id]
  default_kv_id         = azurerm_key_vault.kv.id
  linked_custom_service = local.linked_custom_service
}

# resource "null_resource" "run_terraform_graph_script" {
#   triggers = {
#     script_hash = sha256(timestamp())
#   }
#   provisioner "local-exec" {
#     command     = "./script/graphgen.ps1"
#     quiet       = false
#     interpreter = ["pwsh", "-Command"]
#   }
# }


# terraform graph > graph.dot && Get-Content graph.dot | out-file -encoding utf8NoBOM graph_utf8.dot && dot -Tpng graph_utf8.dot -o graph.png