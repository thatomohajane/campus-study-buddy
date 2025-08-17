# Production Environment Configuration
# This file contains environment-specific variables for the production environment

project_name = "campus-study-buddy"
environment  = "prod"
location     = "South Africa North"

# Resource sizing for production
database_sku_name                = "" # empty => using Postgres flexible server
database_max_size_gb             = 20
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS" # keep local redundant to avoid extra costs
static_web_app_sku_tier          = "Free"
web_pubsub_sku                   = "Free_F1"

# Container Apps configuration (keep conservative to stay within free/min-cost)
container_apps_cpu_limit    = "0.25"
container_apps_memory_limit = "512Mi"
container_apps_min_replicas = 0
container_apps_max_replicas = 2

# Network configuration - Optimized for small-scale application
vnet_address_space                     = ["10.0.0.0/24"]  # 256 IPs total - plenty for small app
database_subnet_address_prefixes       = ["10.0.0.0/28"]  # 16 IPs - more than enough for 1 DB
container_apps_subnet_address_prefixes = ["10.0.0.16/28"] # 16 IPs - enough for 2 replicas + buffer
storage_subnet_address_prefixes        = ["10.0.0.32/28"] # 16 IPs - enough for private endpoints

# Key Vault configuration
# Keep soft-delete retention to the minimum allowed so key vaults become purgeable sooner during testing
key_vault_soft_delete_retention_days = 7 # Minimum retention to allow faster purge during tests

# B2C Configuration for student authentication
b2c_tenant_name   = "studybuddy"   # Creates studybuddy.onmicrosoft.com
b2c_signin_policy = "signupsignin" # B2C_1_signupsignin policy

# Common tags for production environment
tags = {
  Environment = "Production"
  Project     = "campus-study-buddy"
  Owner       = "DevOps"
  ManagedBy   = "terraform"
  Purpose     = "Production environment for campus study buddy application"
}
