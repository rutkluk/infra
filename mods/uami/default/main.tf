


// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "this" {
  name = var.name
  resource_group_name = var.resource_group_name
  location = var.location
  tags = var.tags
}





// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential
resource "azurerm_federated_identity_credential" "this" {
  for_each = var.federated_identity_credentials

  name                = each.value["name"]
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = each.value["audiences"]
  issuer              = each.value["issuer"]
  subject             = each.value["subject"]
}
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
// https://learn.microsoft.com/en-us/azure/role-based-access-control/overview
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
resource "azurerm_role_assignment" "this" {
  for_each             = var.scopes
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  scope                = each.value.scope
  role_definition_name = each.value.role_name
}
