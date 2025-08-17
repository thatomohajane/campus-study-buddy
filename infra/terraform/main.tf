# Campus Study Buddy - Main Terraform Configuration
# This file defines the core infrastructure for the Campus Study Buddy platform

# Random string for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Main Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

// Core infrastructure module (storage, database, key vault)
module "core" {
  source = "./modules/core"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  random_suffix       = random_string.suffix.result
  tags                = local.common_tags

  # Database configuration
  database_admin_username = var.database_admin_username
  database_admin_password = var.database_admin_password
  create_managed_db       = true
  database_sku_name       = "GP_S_Gen5_1" # serverless/general purpose SKU — override via variables.tf if needed
  database_max_size_gb    = var.database_max_size_gb

  # Storage configuration
  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type

  # Key Vault configuration
  key_vault_soft_delete_retention_days = var.key_vault_soft_delete_retention_days

}

# Compute Resources Module
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  random_suffix       = random_string.suffix.result
  tags                = local.common_tags

  # Dependencies
  key_vault_id       = module.core.key_vault_id
  storage_account_id = module.core.storage_account_id
  subnet_id          = module.network.container_apps_subnet_id

  # Container Apps configuration
  container_apps_cpu_limit    = var.container_apps_cpu_limit
  container_apps_memory_limit = var.container_apps_memory_limit
  container_apps_min_replicas = var.container_apps_min_replicas
  container_apps_max_replicas = var.container_apps_max_replicas
  api_container_image         = var.api_container_image

  # Static Web App configuration
  static_web_app_sku_tier = var.static_web_app_sku_tier
}

// Networking module (VNet, subnets, NSGs, route tables)
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  tags                = local.common_tags

  # VNet configuration
  vnet_address_space = var.vnet_address_space

  # Subnet configurations
  database_subnet_address_prefixes       = var.database_subnet_address_prefixes
  container_apps_subnet_address_prefixes = var.container_apps_subnet_address_prefixes
  storage_subnet_address_prefixes        = var.storage_subnet_address_prefixes
}

// Communication services module (Web PubSub, Notification Hubs, Communication Services)
module "communication" {
  source = "./modules/communication"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  random_suffix       = random_string.suffix.result
  tags                = local.common_tags

  # Web PubSub configuration
  web_pubsub_sku = var.web_pubsub_sku

  # Ensure Web PubSub secrets are stored in Key Vault
  key_vault_id = module.core.key_vault_id
}

// Identity and security module (Azure AD app, SP, groups, secrets)
module "identity" {
  source = "./modules/identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  tags                = local.common_tags

  # Key Vault reference
  key_vault_id = module.core.key_vault_id

  # Application configuration
  application_name  = "${local.naming_prefix}-app"
  frontend_hostname = module.compute.static_web_app_default_hostname

  # B2C Configuration
  b2c_tenant_name   = var.b2c_tenant_name
  b2c_signin_policy = var.b2c_signin_policy
}

// Automation module (Logic Apps, Service Bus, automation monitoring)
module "automation" {
  source = "./modules/automation"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  naming_prefix       = local.naming_prefix
  tags                = local.common_tags

  # Dependencies
  storage_account_name = module.core.storage_account_name
}
