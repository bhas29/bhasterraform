# Variable to define role assignments, allowing flexibility in input structure.
variable "role_assignments" {
  type = any # Accepts any data type to support different role assignment configurations.
}

# Variable to define custom role definitions, with a default empty object to allow optional configuration.
variable "role_definitions" {
  type    = any # Accepts any data type to accommodate different role definition structures.
  default = {}  # Defaults to an empty object, meaning no custom roles are defined unless explicitly provided.
}
