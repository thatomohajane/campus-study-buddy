################################################################################
# Module: core
# Purpose: Provision storage account, Azure SQL Server & Database, Key Vault.
# Inputs: resource_group_name, location, naming_prefix, database_admin_username/password, storage configuration, key vault settings, tags
# Outputs: storage_account_id, postgres_server_fqdn, postgres_database_name, key_vault_id
# Provision order in this module: storage -> SQL server & database -> key vault -> secrets -> outputs
# Best practices: store secrets in Key Vault, restrict public access to PaaS endpoints in prod, enable retention and diagnostic settings, use managed identities.
################################################################################

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "azurerm_client_config" "current" {}

# ==============================================================================
# STORAGE ACCOUNT
# ==============================================================================

resource "azurerm_storage_account" "main" {
  name                = "${replace(var.naming_prefix, "-", "")}st${var.random_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  # Network rules
  network_rules {
    default_action = var.storage_network_default_action
    bypass         = ["AzureServices"]
  }

  # Blob properties
  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 7

    delete_retention_policy {
      days = 1
    }

    container_delete_retention_policy {
      days = 1
    }
  }

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

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "${var.naming_prefix}-kv-${var.random_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_purge_protection_enabled

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
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

# Store SQL Database connection string in Key Vault
resource "azurerm_key_vault_secret" "database_connection_string" {
  count        = var.create_managed_db ? 1 : 0
  name         = "database-connection-string"
  value        = var.create_managed_db ? "Server=tcp:${azurerm_mssql_server.main[0].fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.main[0].name};User Id=${var.database_admin_username};Password=${var.database_admin_password};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;" : ""
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

// Azure SQL Server + Database (serverless SKU)
resource "azurerm_mssql_server" "main" {
  count               = var.create_managed_db ? 1 : 0
  name                = "${var.naming_prefix}-sql-${var.random_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login          = var.database_admin_username
  administrator_login_password = var.database_admin_password

  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  count     = var.create_managed_db ? 1 : 0
  name      = "${var.naming_prefix}-db"
  server_id = azurerm_mssql_server.main[0].id

  max_size_gb    = var.database_max_size_gb
  sku_name       = "GP_S_Gen5_1" # Serverless General Purpose
  zone_redundant = false

  tags = var.tags
}
