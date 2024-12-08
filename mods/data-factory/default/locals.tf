locals {
  name                = "az-adf-dev-westeurope-001"
  umi_identity_id     = try(tolist(var.identity_ids)[0])
  umi_name            = try(regex("[^/]+$", local.umi_identity_id))
  umi_credential_name = try("${local.umi_name}-default-credentials")













  linkedservice_azure_function_name     = "SLS_AzureFunctionApp"
  linkedservice_keyvault_name           = "SLS_AzureKeyVault"
  linkedservice_generic_kv_prefix       = "GLS_AzureKeyVault_"
  linkedservice_generic_adls_prefix     = "GLS_AzureBlobFS_"
  linkedservice_generic_blob_prefix     = "GLS_AzureBlobStorage_"
  linkedservice_generic_azuresql_prefix = "GLS_AzureSqlDatabase_"
  linkedservice_generic_synapse_prefix  = "GLS_AzureSqlDW_"
  linkedservice_generic_mssql_prefix    = "GLS_SqlServerDatabase_"
  linkedservice_generic_file_prefix     = "GLS_FileServer_"
  linkedservice_generic_rest_prefix     = "GLS_RestService_Auth"
  linkedservice_generic_oracledb_prefix = "GLS_OracleDB_"
}