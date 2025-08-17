################################################################################
# Module: compute
# Purpose: Create Container Apps environment, API container app(s), Static Web App (frontend), managed identities and RBAC.
# Inputs: resource_group_name, location, naming_prefix, key_vault_id, storage_account_id, subnet_id, container app sizing, api_container_image, tags
# Outputs: api_container_app_fqdn, static_web_app_default_hostname, container app environment id
# Provision order in this module: container apps environment -> container apps -> static web app -> managed identity -> RBAC
# Best practices: use managed identities for secrets, reference Key Vault secrets via identities, keep app settings minimal and secret-backed.
################################################################################

# ==============================================================================
# CONTAINER APPS ENVIRONMENT
# ==============================================================================

resource "azurerm_container_app_environment" "main" {
  name                     = "${var.naming_prefix}-cae"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  infrastructure_subnet_id = var.subnet_id

  tags = var.tags
}

# ==============================================================================
# CONTAINER APPS
# ==============================================================================

# API Container App
resource "azurerm_container_app" "api" {
  name                         = "${var.naming_prefix}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    min_replicas = var.container_apps_min_replicas
    max_replicas = var.container_apps_max_replicas

    container {
      name   = "api"
      image  = var.api_container_image
      cpu    = var.container_apps_cpu_limit
      memory = var.container_apps_memory_limit

      env {
        name  = "NODE_ENV"
        value = var.environment
      }

      env {
        name  = "PORT"
        value = "3000"
      }

      env {
        name        = "DATABASE_URL"
        secret_name = "database-connection-string"
      }

      env {
        name        = "JWT_SECRET"
        secret_name = "jwt-secret"
      }

      env {
        name  = "JWT_EXPIRES_IN"
        value = "7d"
      }

      env {
        name        = "WEBPUBSUB_CONNECTION_STRING"
        secret_name = "web-pubsub-connection-string"
      }

      env {
        name        = "AZURE_STORAGE_CONNECTION_STRING"
        secret_name = "storage-connection-string"
      }

      env {
        name  = "AZURE_STORAGE_CONTAINER_NAME"
        value = "uploads"
      }

      env {
        name  = "CORS_ORIGIN"
        value = var.cors_origin
      }

      env {
        name  = "RATE_LIMIT_WINDOW_MS"
        value = "900000"
      }

      env {
        name  = "RATE_LIMIT_MAX_REQUESTS"
        value = "100"
      }
    }

    # HTTP scaling rule
    http_scale_rule {
      name                = "http-rule"
      concurrent_requests = 30
    }
  }

  # Ingress configuration
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    transport                  = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # Secrets from Key Vault
  secret {
    name                = "database-connection-string"
    key_vault_secret_id = "${var.key_vault_id}/secrets/database-connection-string"
    identity            = azurerm_user_assigned_identity.container_apps.id
  }

  secret {
    name                = "jwt-secret"
    key_vault_secret_id = "${var.key_vault_id}/secrets/jwt-secret"
    identity            = azurerm_user_assigned_identity.container_apps.id
  }

  secret {
    name                = "storage-connection-string"
    key_vault_secret_id = "${var.key_vault_id}/secrets/storage-connection-string"
    identity            = azurerm_user_assigned_identity.container_apps.id
  }

  secret {
    name                = "web-pubsub-connection-string"
    key_vault_secret_id = "${var.key_vault_id}/secrets/web-pubsub-connection-string"
    identity            = azurerm_user_assigned_identity.container_apps.id
  }

  # Managed identity for Key Vault access
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.container_apps_key_vault_secrets_user
  ]
}

# ==============================================================================
# STATIC WEB APP
# ==============================================================================

# Static Web App - Use supported region
resource "azurerm_static_web_app" "frontend" {
  name                = "${var.naming_prefix}-frontend"
  resource_group_name = var.resource_group_name

  # Fixed: Use region that supports Static Web Apps
  location = "West Europe" # Hardcode supported region for Static Web Apps

  sku_tier = "Free"
  sku_size = "Free"

  tags = var.tags
}

# ==============================================================================
# MANAGED IDENTITIES
# ==============================================================================

resource "azurerm_user_assigned_identity" "container_apps" {
  name                = "${var.naming_prefix}-container-apps-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# ==============================================================================
# RBAC ASSIGNMENTS
# ==============================================================================

# Key Vault Secrets User role for Container Apps identity
resource "azurerm_role_assignment" "container_apps_key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.container_apps.principal_id
}

# Storage Blob Data Contributor role for Container Apps
resource "azurerm_role_assignment" "container_apps_storage_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.container_apps.principal_id
}

# ==============================================================================
# APPLICATION GATEWAY (Optional for future use)
# ==============================================================================

# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway" {
  name                = "${var.naming_prefix}-appgw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Application Gateway subnet (would need to be added to networking module)
# Commented out for now as it requires additional subnet configuration
/*
resource "azurerm_application_gateway" "main" {
  name                = "${var.naming_prefix}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_port {
    name = "frontend-port-80"
    port = 80
  }

  frontend_port {
    name = "frontend-port-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name = "backend-pool"
    fqdns = [azurerm_container_app.api.latest_revision_fqdn]
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 1
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = var.tags
}
*/
