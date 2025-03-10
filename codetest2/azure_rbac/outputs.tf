# Output the created role assignments, exposing the resource details for further use.
output "role_assignments" {
  value = azurerm_role_assignment.role
}

# Output the created custom role definitions, allowing access to their properties.
output "role_definitions" {
  value = azurerm_role_definition.custom
}
