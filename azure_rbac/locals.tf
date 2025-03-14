locals {
  ### Index (key) is a combination of the display name, role, and scope
  ### Replace spaces in display name and role with dashes, as whitespaces are not best practices for indexes within the state file
  role_assignments = flatten(
    [for key_ra, ra in var.role_assignments :
      [for key_role, role in ra.roles :
        [for key_scope, scope in role.scopes :
          {
            # Unique key for each role assignment, ensuring proper state tracking
            key = "${replace(key_ra, " ", "-")}-${replace(key_role, " ", "-")}-${key_scope}"

            # General role assignment details
            display_name = try(ra.display_name, null)
            object_id    = try(ra.object_id, null)
            upn          = ra.type == "User" ? ra.upn : null
            type         = ra.type

            # Role and scope mapping
            role                     = key_role
            scope                    = scope
            existing_role_definition = try(role.existing_role_definition, false)

            # Additional role assignment properties
            description                            = try(role.description, null)
            skip_service_principal_aad_check       = try(role.skip_service_principal_aad_check, false)
            condition                              = try(role.condition, null)
            condition_version                      = try(role.condition_version, null)
            delegated_managed_identity_resource_id = try(role.delegated_managed_identity_resource_id, null)
          }
  ]]])
}
