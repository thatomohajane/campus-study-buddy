# Core Infrastructure Module - Variables
# Input variables for the core infrastructure module

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "The deployment environment (staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "naming_prefix" {
  description = "The naming prefix for resources"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for unique resource naming"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Database configuration
variable "database_admin_username" {
  description = "The administrator username for the SQL database"
  type        = string
}

variable "database_admin_password" {
  description = "The administrator password for the SQL database"
  type        = string
  sensitive   = true
}

# Storage configuration
variable "storage_account_tier" {
  description = "The performance tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"
}

# Key Vault configuration
variable "key_vault_soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
  default     = 7
}

# Optionally configure an Azure AD administrator for the SQL server
variable "azuread_administrator_object_id" {
  description = "The object id of an Azure AD user or service principal to configure as SQL administrator. Empty string disables AAD admin."
  type        = string
  default     = ""
}

variable "azuread_administrator_upn" {
  description = "The user principal name (UPN) of the Azure AD administrator to configure for SQL."
  type        = string
  default     = ""
}

# Key Vault purge protection (default false for safe destroy in test environments)
variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection on the Key Vault (recommended for production)."
  type        = bool
  default     = false
}

# Storage network rules default action (Allow or Deny)
variable "storage_network_default_action" {
  description = "Default network action for the storage account network rules (Allow or Deny)."
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.storage_network_default_action)
    error_message = "storage_network_default_action must be either 'Allow' or 'Deny'."
  }
}

# Toggle public network access for SQL Server (use false to require private endpoints/VNet)
variable "sql_public_network_access_enabled" {
  description = "Enable public network access for the Azure SQL Server. Set to false for VNet-only access."
  type        = bool
  default     = false
}

# Database SKU and sizing (allow module-level overrides)
variable "database_sku_name" {
  description = "The SKU name for the SQL database"
  type        = string
  default     = "" # empty => prefer Postgres flexible server or no managed DB by default
}

variable "database_engine_version" {
  description = "The major engine version for PostgreSQL (e.g. '11', '12', '13', '14')"
  type        = string
  default     = "14"
}

variable "database_max_size_gb" {
  description = "The maximum size of the database in GB"
  type        = number
  default     = 20
}

# Whether to create a managed database (Postgres) in this module. Default false to avoid charges.
variable "create_managed_db" {
  description = "When true, create a managed PostgreSQL server and database (single-server)."
  type        = bool
  default     = false
}

