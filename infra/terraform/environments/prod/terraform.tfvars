# Campus Study Buddy - Production Environment Configuration

# ==============================================================================
# BASIC CONFIGURATION
# ==============================================================================
environment  = "prod"
project_name = "campus-study-buddy"

# Fixed: Shorter naming prefix to avoid length issues
naming_prefix = "csb-prod"

# Fixed: Use supported region for Static Web Apps
location = "westeurope"

# Generate random suffix for unique naming
random_suffix = "6xlaji5u"

# ==============================================================================
# IDENTITY CONFIGURATION
# ==============================================================================
application_name       = "Campus Study Buddy"
frontend_hostname      = "campus-study-buddy.azurestaticapps.net"
b2c_tenant_name        = "campusstudybuddy"
b2c_signin_policy      = "signupsignin"
enable_azure_ad_groups = false

# ==============================================================================
# NETWORKING CONFIGURATION  
# ==============================================================================
vnet_address_space               = ["10.0.0.0/16"]
database_subnet_address_prefixes = ["10.0.1.0/24"]
compute_subnet_address_prefixes  = ["10.0.2.0/24"]
storage_subnet_address_prefixes  = ["10.0.3.0/24"]

# ==============================================================================
# DATABASE CONFIGURATION
# ==============================================================================
database_admin_username = "sqladmin"
database_sku_name       = "Basic"
database_max_size_gb    = 2
create_managed_db       = true
enable_sql_database     = true

# ==============================================================================
# COMPUTE CONFIGURATION
# ==============================================================================
container_app_min_replicas = 0
container_app_max_replicas = 10

# ==============================================================================
# STORAGE CONFIGURATION
# ==============================================================================
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"

# ==============================================================================
# SECURITY CONFIGURATION
# ==============================================================================
enable_private_endpoints = true
allowed_ip_ranges        = ["0.0.0.0/0"]

# ==============================================================================
# TAGS
# ==============================================================================
tags = {
  Environment = "production"
  Project     = "campus-study-buddy"
  ManagedBy   = "terraform"
  Owner       = "development-team"
}
