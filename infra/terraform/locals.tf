// Local values used across the Terraform configuration
// Defines common tags, naming prefix, resource group name, and helpers.

locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "campus-study-buddy"
    ManagedBy   = "terraform"
    Owner       = "DevOps"
    Purpose     = "Production environment for campus study buddy application"
  })
  # Naming convention
  naming_prefix = "${var.project_name}-${var.environment}"

  # Resource group name
  resource_group_name = "${local.naming_prefix}-rg"

  # Location short name mapping for Azure for Students (South Africa regions)
  location_short = {
    "South Africa North" = "san"
    "South Africa West"  = "saw"
  }
}
