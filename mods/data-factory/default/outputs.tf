output "id" {
  value       = azurerm_data_factory.this.id
  description = "Data Factory (V2) id."
}

output "uami_credential_reference_name" {
  value = local.umi_credential_name
  description = "Data Factory Key Vault Credential Reference Name"
}