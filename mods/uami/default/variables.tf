variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "federated_identity_credentials" {
  description = "A map of federated identity credentials to create for this Managed identity."

  type = map(object({
    name      = string
    audiences = optional(list(string), ["api://AzureADTokenExchange"])
    issuer    = string
    subject   = string
  }))

  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
variable "scopes" {
  type = map(object({
    scope     = string
    role_name = string
  }))
  default = {}
}