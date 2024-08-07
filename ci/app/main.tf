resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location

  lifecycle {
    prevent_destroy = true # Default is false
  }
}