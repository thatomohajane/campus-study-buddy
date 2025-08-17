# Communication Services Module - Outputs
# Output values from the communication services module

# Web PubSub outputs
output "web_pubsub_name" {
  description = "The name of the Web PubSub service"
  value       = azurerm_web_pubsub.main.name
}

output "web_pubsub_id" {
  description = "The ID of the Web PubSub service"
  value       = azurerm_web_pubsub.main.id
}

output "web_pubsub_hostname" {
  description = "The hostname of the Web PubSub service"
  value       = azurerm_web_pubsub.main.hostname
}

output "web_pubsub_primary_connection_string" {
  description = "The primary connection string for Web PubSub"
  value       = azurerm_web_pubsub.main.primary_connection_string
  sensitive   = true
}

output "web_pubsub_secondary_connection_string" {
  description = "The secondary connection string for Web PubSub"
  value       = azurerm_web_pubsub.main.secondary_connection_string
  sensitive   = true
}

output "web_pubsub_primary_access_key" {
  description = "The primary access key for Web PubSub"
  value       = azurerm_web_pubsub.main.primary_access_key
  sensitive   = true
}

output "web_pubsub_secondary_access_key" {
  description = "The secondary access key for Web PubSub"
  value       = azurerm_web_pubsub.main.secondary_access_key
  sensitive   = true
}

# Web PubSub Hub outputs
output "web_pubsub_hub_name" {
  description = "The name of the Web PubSub hub"
  value       = azurerm_web_pubsub_hub.chat_hub.name
}

output "web_pubsub_hub_id" {
  description = "The ID of the Web PubSub hub"
  value       = azurerm_web_pubsub_hub.chat_hub.id
}

# Notification Hub outputs
output "notification_hub_namespace_name" {
  description = "The name of the Notification Hub namespace"
  value       = azurerm_notification_hub_namespace.main.name
}

output "notification_hub_namespace_id" {
  description = "The ID of the Notification Hub namespace"
  value       = azurerm_notification_hub_namespace.main.id
}

output "notification_hub_name" {
  description = "The name of the Notification Hub"
  value       = azurerm_notification_hub.main.name
}

output "notification_hub_id" {
  description = "The ID of the Notification Hub"
  value       = azurerm_notification_hub.main.id
}

# Communication Service outputs
// Azure Communication Service removed to avoid paid SMS/email features. Use external providers if needed.
