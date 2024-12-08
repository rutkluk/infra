output "id" {
  description = "The ID of this Managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "The client ID of this Managed identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "name" {
  description = "The client ID of this Managed identity."
  value       = azurerm_user_assigned_identity.this.name
}

output "identity_principal_id" {
  description = "The principal (object) ID of this Managed identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "identity_tenant_id" {
  description = "The tenant ID of this Managed identity."
  value       = azurerm_user_assigned_identity.this.tenant_id
}