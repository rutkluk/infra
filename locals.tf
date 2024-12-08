locals {
  linked_custom_service = [
    {
      name                 = "KeyVault"
      type                 = "AzureKeyVault"
      description          = "managed by terraform"
      enabled              = true
      type_properties_json = <<JSON
        {
          "baseUrl" : "@{linkedService().KeyVaultBaseUrl}",
          "credential" : {
            "referenceName" : "${module.adf.uami_credential_reference_name}",
            "type" : "CredentialReference"
          }
        }
      JSON
      parameter = {
        KeyVaultBaseUrl      = azurerm_key_vault.kv.vault_uri
        AnotherTestParameter = "test map(string)"
      }
    }
    ,
    {
      name                 = "SqlServerSQLAuth"
      type                 = "SqlServer"
      enabled              = true
      description          = "Managed By Terraform"
      integration_runtime  = "SelfHostedRuntimeOnPrem"
      type_properties_json = <<JSON
        {
          "connectionString" : "Integrated Security=True;Data Source=@{linkedService().Server};Initial Catalog=@{linkedService().Database};User ID=@{linkedService().UserName}",
          "password" : {
            "type" : "AzureKeyVaultSecret",
            "store" : {
              "referenceName" : "KeyVault",
              "type" : "LinkedServiceReference",
              "parameters" : {
                "KeyVaultBaseUrl" : {
                  "value" : "@linkedService().KeyVaultBaseUrl",
                  "type" : "Expression"
                }
              }
            },
            "secretName" : {
              "value" : "@linkedService().PasswordSecret",
              "type" : "Expression"
            }
          }
        }
      JSON
      parameter = {
        Server          = "abs"
        Database        = "cde"
        KeyVaultBaseUrl = azurerm_key_vault.kv.vault_uri
        PasswordSecret  = "databasedb"
        UserName        = "test"
      }
    },
    {

      name                 = "Dataverse"
      type                 = "CommonDataServiceForApps"
      enabled              = true
      integration_runtime  = "integrationRuntime1"
      description          = "Generic CommonDataServiceForApps"
      type_properties_json = <<JSON
        {
          "deploymentType" : "Online",
          "serviceUri" : "https://google.crm4.com",
          "authenticationType" : "ManagedIdentity",
          "credential": {
                "referenceName": "id5617-default-credentials",
                "type": "CredentialReference"
          }
        }
      JSON
      parameter = {
        AnotherTestParameter = "test map(string)"
      }
    }
  ]
}