################################################################################
# Module: core
# Purpose: Provision storage account, Azure SQL Server & Database, Key Vault.
################################################################################

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "azurerm_client_config" "current" {}

# ==============================================================================
# RESOURCE GROUP
# ==============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ==============================================================================
# STORAGE ACCOUNT
# ==============================================================================

resource "azurerm_storage_account" "main" {
  # Fixed: Ensure name is 3-24 chars, lowercase alphanumeric only
  name                = substr(replace("${replace(var.naming_prefix, "-", "")}st${var.random_suffix}", "_", ""), 0, 24)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  
  # Security settings
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  
  tags = var.tags
}

# Storage containers for different purposes
resource "azurerm_storage_container" "user_files" {
  name                  = "user-files"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "study_materials" {
  name                  = "study-materials"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "profile_images" {
  name                  = "profile-images"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "temp_uploads" {
  name                  = "temp-uploads"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# ==============================================================================
# KEY VAULT
# ==============================================================================

resource "azurerm_key_vault" "main" {
  # Fixed: Ensure name is 3-24 chars, alphanumeric and dashes only
  name                = substr("${var.naming_prefix}-kv-${var.random_suffix}", 0, 24)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "standard"
  
  # Access policies
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]
  }
  
  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]

  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  ]
}

# ==============================================================================
# SQL SERVER & DATABASE
# ==============================================================================

resource "azurerm_mssql_server" "main" {
  count               = var.create_managed_db ? 1 : 0
  name                = "${var.naming_prefix}-sql-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  administrator_login          = var.database_admin_username
  administrator_login_password = var.database_admin_password

  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  count      = var.create_managed_db ? 1 : 0
  name       = "${var.naming_prefix}-db"
  server_id  = azurerm_mssql_server.main[0].id
  
  # Fixed: Use Basic tier without min_capacity
  sku_name   = var.database_sku_name
  max_size_gb = var.database_max_size_gb
  
  tags = var.tags
}

# ==============================================================================
# KEY VAULT SECRETS
# ==============================================================================

# Store SQL Database connection string in Key Vault
resource "azurerm_key_vault_secret" "database_connection_string" {
  count        = var.create_managed_db ? 1 : 0
  name         = "database-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.main[0].fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.main[0].name};User Id=${var.database_admin_username};Password=${var.database_admin_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current]
  tags = var.tags
}

# Store storage account connection string in Key Vault
resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "storage-connection-string"
  value        = azurerm_storage_account.main.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current]
  tags = var.tags
}

# JWT secret for application session signing
resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = random_string.jwt_secret.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current]
  tags = var.tags
}

resource "random_string" "jwt_secret" {
  length  = 32
  special = true
  upper   = false
}
