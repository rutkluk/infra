variable "location" {
  type        = string
  description = "Resource location."
  default     = "West Europe"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name."
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Whether a managed virtual network is enabled in this ADF"
  default     = true
}

variable "public_network_enabled" {
  type        = bool
  description = "Whether public network is enabled"
  default     = false
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the Data Factory (V2)."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type(s) of the Data Factory (V2)."
  type        = string
  default     = "SystemAssigned"
}

variable "global_parameter" {
  description = "The global parameter blocks if used"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = null
}

variable "github_configuration" {
  description = "The github configuration block if used"
  type = object({
    account_name       = string
    branch_name        = string
    git_url            = string
    repository_name    = string
    root_folder        = string
    publishing_enabled = optional(bool, true)
  })
  default = null
}

variable "purview_id" {
  type        = string
  description = "The purview id if used"
  default     = null
}

variable "lcs" {
type = list(object({
  name                  = optional(string)
    type                  = optional(string)
    description = optional(string)
    enabled = optional(bool)
    integration_runtime = optional(string)
    type_properties_json  = optional(string)
    parameter = optional(map(string))
    annotations = optional(list(string))
    ir_parameter = optional(map(string))
})
)
default = [ {
} ]
}

variable "linked_custom_service" {
type = list(object({
  name                  = optional(string)
    type                  = optional(string)
    description = optional(string)
    enabled = optional(bool)
    integration_runtime = optional(string)
    type_properties_json  = optional(string)
    parameter = optional(map(string))
    annotations = optional(list(string))
    ir_parameter = optional(map(string))
})
)
default = [ {
} ]
}



# variable "lcs" {
# type = list(object({
#   name                  = optional(string)
#     type                  = optional(string)
#     description = optional(string)
#     enabled = optional(bool)
#     integration_runtime = optional(string)
#     type_properties_json  = optional(string)
#     parameter = optional(object({
#         Server          = optional(string)
#     Database        = optional(string)
#     KeyVaultBaseUrl = optional(string)
#     PasswordSecret  = optional(string)
#     UserName        = optional(string)
#     ReferenceName        = optional(string)
#     }))
# })
# )
# default = [ {
# } ]
# }



# variable "lcs" {
#   type = list(object({
#     name                  = string
#     type                  = string
#     enabled               = bool
#     vault_uri             = string
#     authentication_method = string
#   }))
#   default = [
#     {
#       name                  = "instance A"
#       type                  = "t2.micro"
#       enabled               = true
#       vault_uri             = ""
#       authentication_method = ""
#     }
#   ]
# }

# variable "lcs2" {
#   type = map(string)
#   nullable = true
# }


# variable "default_kv_name" {
#   type        = string
# }

variable "default_kv_id" {
  type        = string
}