# storage accounts
#testing 1
#tesing full checkov
#testing with updated step 6
#testing with checkov,fmt and lint
resource "azurerm_storage_account" "sa" {
  name                              = var.storage.name                                                          # Set the name of the storage account
  resource_group_name               = coalesce(lookup(var.storage, "resource_group", null), var.resource_group) # Determine the resource group name
  location                          = coalesce(lookup(var.storage, "location", null), var.location)             # Set the location for the storage account
  account_tier                      = try(var.storage.account_tier, "Standard")                                 # Set the account tier, defaulting to Standard
  account_replication_type          = try(var.storage.account_replication_type, "GRS")                          # Set the replication type, defaulting to GRS
  account_kind                      = try(var.storage.account_kind, "StorageV2")                                # Set the account kind, defaulting to StorageV2
  access_tier                       = try(var.storage.access_tier, "Hot")                                       # Set the access tier, defaulting to Hot
  infrastructure_encryption_enabled = try(var.storage.infrastructure_encryption_enabled, false)                 # Enable infrastructure encryption if specified
  https_traffic_only_enabled        = try(var.storage.https_traffic_only_enabled, true)                         # Enforce HTTPS traffic only
  min_tls_version                   = try(var.storage.min_tls_version, "TLS1_2")                                # Set the minimum TLS version, defaulting to TLS1_2
  edge_zone                         = try(var.storage.edge_zone, null)                                          # Set the edge zone if specified
  table_encryption_key_type         = try(var.storage.table_encryption_key_type, null)                          # Set the table encryption key type if specified
  queue_encryption_key_type         = try(var.storage.queue_encryption_key_type, null)                          # Set the queue encryption key type if specified
  allowed_copy_scope                = try(var.storage.allowed_copy_scope, null)                                 # Set the allowed copy scope if specified
  large_file_share_enabled          = try(var.storage.large_file_share_enabled, false)                          # Enable large file share if specified
  allow_nested_items_to_be_public   = try(var.storage.allow_nested_items_to_be_public, false)                   # Allow nested items to be public if specified
  shared_access_key_enabled         = try(var.storage.shared_access_key_enabled, true)                          # Enable shared access key by default
  public_network_access_enabled     = try(var.storage.public_network_access_enabled, true)                      # Enable public network access by default
  is_hns_enabled                    = try(var.storage.is_hns_enabled, false)                                    # Enable hierarchical namespace if specified
  sftp_enabled                      = try(var.storage.sftp_enabled, false)                                      # Enable SFTP if specified
  nfsv3_enabled                     = try(var.storage.nfsv3_enabled, false)                                     # Enable NFSv3 if specified
  cross_tenant_replication_enabled  = try(var.storage.cross_tenant_replication_enabled, false)                  # Enable cross-tenant replication if specified
  local_user_enabled                = try(var.storage.local_user_enabled, null)                                 # Enable local user if specified
  dns_endpoint_type                 = try(var.storage.dns_endpoint_type, null)                                  # Set the DNS endpoint type if specified
  default_to_oauth_authentication   = try(var.storage.default_to_oauth_authentication, false)                   # Enable default OAuth authentication if specified
  tags                              = try(var.storage.tags, var.tags, null)                                     # Set tags for the storage account

  dynamic "network_rules" {                                                                    # Define dynamic network rules
    for_each = try(var.storage.network_rules, null) != null ? [var.storage.network_rules] : [] # Check if network rules are defined

    content {
      bypass                     = try(network_rules.value.bypass, ["None"])                 # Set bypass rules
      default_action             = try(network_rules.value.default_action, "Deny")           # Set default action for network rules
      ip_rules                   = try(network_rules.value.ip_rules, null)                   # Set IP rules if specified
      virtual_network_subnet_ids = try(network_rules.value.virtual_network_subnet_ids, null) # Set virtual network subnet IDs if specified

      dynamic "private_link_access" {                                                                      # Define dynamic private link access
        for_each = { for key, pla in try(var.storage.network_rules.private_link_access, {}) : key => pla } # Iterate over private link access rules

        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id          # Set the endpoint resource ID
          endpoint_tenant_id   = try(private_link_access.value.endpoint_tenant_id, null) # Set the endpoint tenant ID if specified
        }
      }
    }
  }

  dynamic "blob_properties" {                                            # Define dynamic blob properties
    for_each = try(var.storage.blob_properties, null) != null ? [1] : [] # Check if blob properties are defined

    content {
      last_access_time_enabled      = try(var.storage.blob_properties.last_access_time_enabled, false)     # Enable last access time tracking if specified
      versioning_enabled            = try(var.storage.blob_properties.versioning_enabled, false)           # Enable versioning if specified
      change_feed_enabled           = try(var.storage.blob_properties.change_feed_enabled, false)          # Enable change feed if specified
      change_feed_retention_in_days = try(var.storage.blob_properties.change_feed_retention_in_days, null) # Set change feed retention in days if specified
      default_service_version       = try(var.storage.blob_properties.default_service_version, null)       # Set default service version if specified

      dynamic "cors_rule" {                                              # Define dynamic CORS rules
        for_each = lookup(var.storage.blob_properties, "cors_rules", {}) # Get CORS rules if specified

        content {
          allowed_headers    = cors_rule.value.allowed_headers    # Set allowed headers for CORS
          allowed_methods    = cors_rule.value.allowed_methods    # Set allowed methods for CORS
          allowed_origins    = cors_rule.value.allowed_origins    # Set allowed origins for CORS
          exposed_headers    = cors_rule.value.exposed_headers    # Set exposed headers for CORS
          max_age_in_seconds = cors_rule.value.max_age_in_seconds # Set max age for CORS
        }
      }

      dynamic "delete_retention_policy" {                                                                                                            # Define dynamic delete retention policy
        for_each = try(var.storage.blob_properties.delete_retention_policy != null ? [var.storage.blob_properties.delete_retention_policy] : [], []) # Check if delete retention policy is defined

        content {
          days                     = try(delete_retention_policy.value.days, 7)                        # Set retention days for delete policy
          permanent_delete_enabled = try(delete_retention_policy.value.permanent_delete_enabled, null) # Enable permanent delete if specified
        }
      }

      dynamic "restore_policy" {                                                                                                   # Define dynamic restore policy
        for_each = try(var.storage.blob_properties.restore_policy != null ? [var.storage.blob_properties.restore_policy] : [], []) # Check if restore policy is defined

        content {
          days = try(var.storage.blob_properties.restore_policy.days, 7) # Set retention days for restore policy
        }
      }

      dynamic "container_delete_retention_policy" {                                                                                                                      # Define dynamic container delete retention policy
        for_each = try(var.storage.blob_properties.container_delete_retention_policy != null ? [var.storage.blob_properties.container_delete_retention_policy] : [], []) # Check if container delete retention policy is defined

        content {
          days = try(var.storage.blob_properties.container_delete_retention_policy.days, 7) # Set retention days for container delete policy
        }
      }
    }
  }

  dynamic "share_properties" {                                            # Define dynamic share properties
    for_each = try(var.storage.share_properties, null) != null ? [1] : [] # Check if share properties are defined
    content {

      dynamic "cors_rule" {                                               # Define dynamic CORS rules for shares
        for_each = lookup(var.storage.share_properties, "cors_rules", {}) # Get CORS rules if specified

        content {
          allowed_headers    = cors_rule.value.allowed_headers    # Set allowed headers for CORS
          allowed_methods    = cors_rule.value.allowed_methods    # Set allowed methods for CORS
          allowed_origins    = cors_rule.value.allowed_origins    # Set allowed origins for CORS
          exposed_headers    = cors_rule.value.exposed_headers    # Set exposed headers for CORS
          max_age_in_seconds = cors_rule.value.max_age_in_seconds # Set max age for CORS
        }
      }

      dynamic "retention_policy" {                                                                                                       # Define dynamic retention policy for shares
        for_each = try(var.storage.share_properties.retention_policy != null ? [var.storage.share_properties.retention_policy] : [], []) # Check if retention policy is defined

        content {
          days = try(var.storage.share_properties.retention_policy.days, 7) # Set retention days for share policy
        }
      }

      dynamic "smb" {                                                                                          # Define dynamic SMB properties
        for_each = try(var.storage.share_properties.smb != null ? [var.storage.share_properties.smb] : [], []) # Check if SMB properties are defined

        content {
          versions                        = try(var.storage.share_properties.smb.versions, [])                        # Set SMB versions if specified
          authentication_types            = try(var.storage.share_properties.smb.authentication_types, [])            # Set authentication types for SMB
          channel_encryption_type         = try(var.storage.share_properties.smb.channel_encryption_type, [])         # Set channel encryption type for SMB
          multichannel_enabled            = try(var.storage.share_properties.smb.multichannel_enabled, false)         # Enable multichannel if specified
          kerberos_ticket_encryption_type = try(var.storage.share_properties.smb.kerberos_ticket_encryption_type, []) # Set Kerberos ticket encryption type for SMB
        }
      }
    }
  }

  dynamic "azure_files_authentication" {                                                                                                                            # Define dynamic Azure Files authentication
    for_each = try(var.storage.share_properties.azure_files_authentication, null) != null ? { auth = var.storage.share_properties.azure_files_authentication } : {} # Check if Azure Files authentication is defined

    content {
      directory_type                 = try(azure_files_authentication.value.directory_type, "AD")                 # Set directory type, defaulting to AD
      default_share_level_permission = try(azure_files_authentication.value.default_share_level_permission, null) # Set default share level permission if specified

      dynamic "active_directory" {                                                                                                    # Define dynamic Active Directory properties
        for_each = azure_files_authentication.value.directory_type == "AD" ? [azure_files_authentication.value.active_directory] : [] # Check if directory type is AD

        content {
          domain_name         = active_directory.value.domain_name                    # Set domain name for Active Directory
          domain_guid         = active_directory.value.domain_guid                    # Set domain GUID for Active Directory
          forest_name         = try(active_directory.value.forest_name, null)         # Set forest name if specified
          domain_sid          = try(active_directory.value.domain_sid, null)          # Set domain SID if specified
          storage_sid         = try(active_directory.value.storage_sid, null)         # Set storage SID if specified
          netbios_domain_name = try(active_directory.value.netbios_domain_name, null) # Set NetBIOS domain name if specified
        }
      }
    }
  }

  dynamic "queue_properties" {                                            # Define dynamic queue properties
    for_each = try(var.storage.queue_properties, null) != null ? [1] : [] # Check if queue properties are defined
    content {

      dynamic "cors_rule" {                                               # Define dynamic CORS rules for queues
        for_each = lookup(var.storage.queue_properties, "cors_rules", {}) # Get CORS rules if specified

        content {
          allowed_headers    = cors_rule.value.allowed_headers    # Set allowed headers for CORS
          allowed_methods    = cors_rule.value.allowed_methods    # Set allowed methods for CORS
          allowed_origins    = cors_rule.value.allowed_origins    # Set allowed origins for CORS
          exposed_headers    = cors_rule.value.exposed_headers    # Set exposed headers for CORS
          max_age_in_seconds = cors_rule.value.max_age_in_seconds # Set max age for CORS
        }
      }

      dynamic "logging" {                                                                                              # Define dynamic logging properties for queues
        for_each = try(var.storage.queue_properties.logging != null ? [var.storage.queue_properties.logging] : [], []) # Check if logging properties are defined

        content {
          version               = try(var.storage.queue_properties.logging.version, "1.0")           # Set logging version, defaulting to 1.0
          delete                = try(var.storage.queue_properties.logging.delete, false)            # Enable delete logging if specified
          read                  = try(var.storage.queue_properties.logging.read, false)              # Enable read logging if specified
          write                 = try(var.storage.queue_properties.logging.write, false)             # Enable write logging if specified
          retention_policy_days = try(var.storage.queue_properties.logging.retention_policy_days, 7) # Set retention days for logging
        }
      }

      dynamic "minute_metrics" {                                                                                                     # Define dynamic minute metrics for queues
        for_each = try(var.storage.queue_properties.minute_metrics != null ? [var.storage.queue_properties.minute_metrics] : [], []) # Check if minute metrics are defined

        content {
          enabled               = try(var.storage.queue_properties.minute_metrics.enabled, false)           # Enable minute metrics if specified
          version               = try(var.storage.queue_properties.minute_metrics.version, "1.0")           # Set minute metrics version, defaulting to 1.0
          include_apis          = try(var.storage.queue_properties.minute_metrics.include_apis, false)      # Include APIs in minute metrics if specified
          retention_policy_days = try(var.storage.queue_properties.minute_metrics.retention_policy_days, 7) # Set retention days for minute metrics
        }
      }

      dynamic "hour_metrics" {                                                                                                   # Define dynamic hour metrics for queues
        for_each = try(var.storage.queue_properties.hour_metrics != null ? [var.storage.queue_properties.hour_metrics] : [], []) # Check if hour metrics are defined

        content {
          enabled               = try(var.storage.queue_properties.hour_metrics.enabled, false)           # Enable hour metrics if specified
          version               = try(var.storage.queue_properties.hour_metrics.version, "1.0")           # Set hour metrics version, defaulting to 1.0
          include_apis          = try(var.storage.queue_properties.hour_metrics.include_apis, false)      # Include APIs in hour metrics if specified
          retention_policy_days = try(var.storage.queue_properties.hour_metrics.retention_policy_days, 7) # Set retention days for hour metrics
        }
      }
    }
  }

  dynamic "sas_policy" {                                                                               # Define dynamic SAS policy
    for_each = try(var.storage.policy.sas, null) != null ? { "default" = var.storage.policy.sas } : {} # Check if SAS policy is defined

    content {
      expiration_action = sas_policy.value.expiration_action # Set expiration action for SAS policy
      expiration_period = sas_policy.value.expiration_period # Set expiration period for SAS policy
    }
  }

  dynamic "routing" {                                                                            # Define dynamic routing properties
    for_each = try(var.storage.routing, null) != null ? { "default" = var.storage.routing } : {} # Check if routing properties are defined

    content {
      choice                      = try(routing.value.choice, "MicrosoftRouting")         # Set routing choice, defaulting to MicrosoftRouting
      publish_internet_endpoints  = try(routing.value.publish_internet_endpoints, false)  # Publish internet endpoints if specified
      publish_microsoft_endpoints = try(routing.value.publish_microsoft_endpoints, false) # Publish Microsoft endpoints if specified
    }
  }

  dynamic "immutability_policy" {                                                                                        # Define dynamic immutability policy
    for_each = try(var.storage.policy.immutability, null) != null ? { "default" = var.storage.policy.immutability } : {} # Check if immutability policy is defined

    content {
      state                         = immutability_policy.value.state                         # Set the state of the immutability policy
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days # Set the period since creation in days
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes # Allow protected append writes if specified
    }
  }

  dynamic "custom_domain" {                                                                                  # Define dynamic custom domain properties
    for_each = try(var.storage.custom_domain, null) != null ? { "default" = var.storage.custom_domain } : {} # Check if custom domain is defined

    content {
      name          = custom_domain.value.name          # Set the custom domain name
      use_subdomain = custom_domain.value.use_subdomain # Specify if subdomain should be used
    }
  }

  dynamic "customer_managed_key" {                                                                                               # Define dynamic customer managed key properties
    for_each = lookup(var.storage, "customer_managed_key", null) != null ? { "default" = var.storage.customer_managed_key } : {} # Check if customer managed key is defined

    content {
      key_vault_key_id          = try(customer_managed_key.value.key_vault_key_id, null)   # Set the Key Vault key ID if specified
      managed_hsm_key_id        = try(customer_managed_key.value.managed_hsm_key_id, null) # Set the managed HSM key ID if specified
      user_assigned_identity_id = azurerm_user_assigned_identity.identity["identity"].id   # Set the user assigned identity ID
    }
  }

  dynamic "static_website" {                                            # Define dynamic static website properties
    for_each = try(var.storage.static_website, null) != null ? [1] : [] # Check if static website properties are defined

    content {
      index_document     = try(static_website.value.index_document, null)     # Set the index document if specified
      error_404_document = try(static_website.value.error_404_document, null) # Set the error 404 document if specified
    }
  }

  dynamic "identity" {                                                                     # Define dynamic identity properties
    for_each = lookup(var.storage, "identity", null) != null ? [var.storage.identity] : [] # Check if identity is defined
    content {
      type = identity.value.type                                           # Set the identity type
      identity_ids = concat(                                               # Concatenate identity IDs
        try([azurerm_user_assigned_identity.identity["identity"].id], []), # Include user assigned identity ID
        lookup(identity.value, "identity_ids", [])                         # Include additional identity IDs if specified
      )
    }
  }
}

# containers
resource "azurerm_storage_container" "sc" {
  for_each = lookup( # Iterate over storage containers
  lookup(var.storage, "blob_properties", {}), "containers", {})

  name                  = try(each.value.name, join("-", [var.naming.storage_container, each.key])) # Set the container name
  storage_account_id    = azurerm_storage_account.sa.id                                             # Reference the storage account ID
  container_access_type = try(each.value.access_type, "private")                                    # Set the access type for the container
  metadata              = try(each.value.metadata, {})                                              # Set metadata for the container
}

# queues
resource "azurerm_storage_queue" "sq" {
  for_each = try( # Iterate over storage queues
    var.storage.queue_properties.queues, {}
  )

  name                 = try(each.value.name, join("-", [var.naming.storage_queue, each.key])) # Set the queue name
  storage_account_name = azurerm_storage_account.sa.name                                       # Reference the storage account name
  metadata             = try(each.value.metadata, {})                                          # Set metadata for the queue
}

resource "azurerm_storage_account_local_user" "lu" {
  for_each = merge({ # Merge local users from blob and file shares
    for kv in flatten([
      for container_name, container_def in lookup(lookup(var.storage, "blob_properties", {}), "containers", {}) : [
        for user_key, user_def in lookup(container_def, "local_users", {}) : {
          key = "${container_name}-${user_key}" # Create a unique key for each user
          value = {
            service          = "blob"                                            # currently only blob and file is supported  # Specify the service type
            resource_name    = azurerm_storage_container.sc[container_name].name # Reference the container name
            name             = try(user_def.name, user_key)                      # Set the user name
            home_directory   = try(user_def.home_directory, null)                # Set the home directory if specified
            ssh_key_enabled  = try(user_def.ssh_key_enabled, false)              # Enable SSH key if specified
            ssh_pass_enabled = try(user_def.ssh_password_enabled, false)         # Enable SSH password if specified

            ssh_authorized_keys = try( # Set authorized SSH keys if specified
              user_def.ssh_authorized_keys, {}
            )

            permissions = try( # Set permissions for the user
              user_def.permission_scope.permissions, {}
            )
          }
        }
      ]
    ]) : kv.key => kv.value # Create a map of user definitions
    },
    {
      for kv in flatten([ # Iterate over file share local users
        for share_name, share_def in lookup(lookup(var.storage, "share_properties", {}), "shares", {}) : [
          for user_key, user_def in lookup(share_def, "local_users", {}) : {
            key = "${share_name}-${user_key}" # Create a unique key for each user
            value = {
              service          = "file"                                    # Specify the service type
              resource_name    = azurerm_storage_share.sh[share_name].name # Reference the share name
              name             = try(user_def.name, user_key)              # Set the user name
              home_directory   = try(user_def.home_directory, null)        # Set the home directory if specified
              ssh_key_enabled  = try(user_def.ssh_key_enabled, false)      # Enable SSH key if specified
              ssh_pass_enabled = try(user_def.ssh_password_enabled, false) # Enable SSH password if specified

              ssh_authorized_keys = try( # Set authorized SSH keys if specified
                user_def.ssh_authorized_keys, {}
              )

              permissions = try( # Set permissions for the user
                user_def.permission_scope.permissions, {}
              )
            }
          }
        ]
      ]) : kv.key => kv.value # Create a map of user definitions
    }
  )

  name                 = each.value.name               # Set the user name
  ssh_key_enabled      = each.value.ssh_key_enabled    # Enable SSH key if specified
  ssh_password_enabled = each.value.ssh_pass_enabled   # Enable SSH password if specified
  home_directory       = each.value.home_directory     # Set the home directory
  storage_account_id   = azurerm_storage_account.sa.id # Reference the storage account ID

  dynamic "ssh_authorized_key" { # Define dynamic SSH authorized keys
    for_each = try(              # Iterate over authorized SSH keys
      each.value.ssh_authorized_keys, {}
    )

    content {
      description = try(ssh_authorized_key.value.description, null) # Set the description for the SSH key
      key         = ssh_authorized_key.value.key                    # Set the SSH key
    }
  }

  permission_scope {                         # Define permission scope for the user
    service       = each.value.service       # Set the service type
    resource_name = each.value.resource_name # Set the resource name

    permissions {                                        # Define permissions for the user
      read   = try(each.value.permissions.read, false)   # Enable read permission if specified
      write  = try(each.value.permissions.write, false)  # Enable write permission if specified
      create = try(each.value.permissions.create, false) # Enable create permission if specified
      delete = try(each.value.permissions.delete, false) # Enable delete permission if specified
    }
  }
}

# shares
resource "azurerm_storage_share" "sh" {
  for_each = lookup( # Iterate over storage shares
  lookup(var.storage, "share_properties", {}), "shares", {})

  name               = try(each.value.name, join("-", [var.naming.storage_share, each.key])) # Set the share name
  storage_account_id = azurerm_storage_account.sa.id                                         # Reference the storage account ID
  quota              = each.value.quota                                                      # Set the quota for the share
  metadata           = try(each.value.metadata, {})                                          # Set metadata for the share
  access_tier        = try(each.value.access_tier, "Hot")                                    # Set the access tier for the share, defaulting to Hot
  enabled_protocol   = try(each.value.protocol, "SMB")                                       # Set the enabled protocol for the share, defaulting to SMB

  dynamic "acl" {   # Define dynamic ACL for the share
    for_each = try( # Iterate over ACLs
      each.value.acl, {}
    )

    content {
      id = acl.key # Set the ACL ID

      dynamic "access_policy" {                                                  # Define dynamic access policy
        for_each = can(acl.value.access_policy) ? [acl.value.access_policy] : [] # Check if access policy is defined
        content {
          permissions = access_policy.value.permissions       # Set permissions for the access policy
          start       = try(access_policy.value.start, null)  # Set start time for the access policy if specified
          expiry      = try(access_policy.value.expiry, null) # Set expiry time for the access policy if specified
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [ # Ignore changes to specific metadata fields
      metadata["syncsignature"],
      metadata["SyncSignature"]
    ]
  }
}

# tables
resource "azurerm_storage_table" "st" {
  for_each = try( # Iterate over storage tables
    var.storage.tables, {}
  )

  name                 = try(each.value.name, join("-", [var.naming.storage_table, each.key])) # Set the table name
  storage_account_name = azurerm_storage_account.sa.name                                       # Reference the storage account name
}

# file systems
resource "azurerm_storage_data_lake_gen2_filesystem" "fs" {
  for_each = try( # Iterate over file systems
    var.storage.file_systems, {}
  )
  name                     = try(each.value.name, join("-", [var.naming.storage_data_lake_gen2_filesystem, each.key])) # Set the file system name
  storage_account_id       = azurerm_storage_account.sa.id                                                             # Reference the storage account ID
  properties               = try(each.value.properties, {})                                                            # Set properties for the file system
  owner                    = try(each.value.owner, null)                                                               # Set the owner if specified
  group                    = try(each.value.group, null)                                                               # Set the group if specified
  default_encryption_scope = try(each.value.default_encryption_scope, null)                                            # Set the default encryption scope if specified

  dynamic "ace" {                      # Define dynamic access control entries (ACE)
    for_each = try(each.value.ace, {}) # Iterate over ACEs
    content {
      permissions = ace.value.permissions                                                       # Set permissions for the ACE
      type        = ace.value.type                                                              # Set the type of the ACE
      id          = ace.value.type == "group" || ace.value.type == "user" ? ace.value.id : null # Set the ID if type is group or user
      scope       = try(ace.value.scope, "access")                                              # Set the scope for the ACE, defaulting to access
    }
  }
}

resource "azurerm_storage_data_lake_gen2_path" "pa" {
  for_each = merge([ # Merge paths from file systems
    for fs_key, fs in try(var.storage.file_systems, {}) : {
      for pa_key, pa in try(fs.paths, {}) : pa_key => {
        path               = try(pa.path, pa_key)                                      # Set the path
        filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.fs[fs_key].name # Reference the file system name
        storage_account_id = azurerm_storage_account.sa.id                             # Reference the storage account ID
        owner              = try(pa.owner, null)                                       # Set the owner if specified
        group              = try(pa.group, null)                                       # Set the group if specified
        ace                = try(pa.ace, {})                                           # Set ACEs if specified
      }
    }
  ]...)

  path               = each.value.path               # Set the path
  filesystem_name    = each.value.filesystem_name    # Reference the file system name
  storage_account_id = each.value.storage_account_id # Reference the storage account ID
  owner              = each.value.owner              # Set the owner
  group              = each.value.group              # Set the group
  resource           = "directory"                   # currently only directory is supported  # Specify the resource type

  dynamic "ace" {                      # Define dynamic access control entries (ACE)
    for_each = try(each.value.ace, {}) # Iterate over ACEs
    content {
      permissions = ace.value.permissions                                                       # Set permissions for the ACE
      type        = ace.value.type                                                              # Set the type of the ACE
      id          = ace.value.type == "group" || ace.value.type == "user" ? ace.value.id : null # Set the ID if type is group or user
      scope       = try(ace.value.scope, "access")                                              # Set the scope for the ACE, defaulting to access
    }
  }
}

# management policies
resource "azurerm_storage_management_policy" "mgmt_policy" {
  for_each = try(var.storage.management_policy, null) != null ? { "default" = var.storage.management_policy } : {} # Check if management policy is defined

  storage_account_id = azurerm_storage_account.sa.id # Reference the storage account ID

  dynamic "rule" {                                          # Define dynamic rules for the management policy
    for_each = try(var.storage.management_policy.rules, {}) # Iterate over management policy rules

    content {
      name    = try(rule.value.name, rule.key) # Set the rule name
      enabled = try(rule.value.enabled, true)  # Enable the rule by default

      dynamic "filters" {                      # Define dynamic filters for the rule
        for_each = try(rule.value.filters, {}) # Iterate over filters

        content {
          prefix_match = try(filters.value.prefix_match, null) # Set prefix match for the filter
          blob_types   = try(filters.value.blob_types, null)   # Set blob types for the filter

          dynamic "match_blob_index_tag" {                   # Define dynamic match blob index tag
            for_each = try(filters.match_blob_index_tag, {}) # Iterate over match blob index tags

            content {
              name      = try(match_blob_index_tag.value.name, null)      # Set the name for the match blob index tag
              operation = try(match_blob_index_tag.value.operation, null) # Set the operation for the match blob index tag
              value     = try(match_blob_index_tag.value.value, null)     # Set the value for the match blob index tag
            }
          }
        }

      }
      actions {                                            # Define actions for the rule
        dynamic "base_blob" {                              # Define dynamic base blob actions
          for_each = try(rule.value.actions.base_blob, {}) # Iterate over base blob actions

          # provider injects -1 in the plan, even when it is not specified in the config
          content {
            tier_to_cool_after_days_since_modification_greater_than        = try(base_blob.value.tier_to_cool_after_days_since_modification_greater_than, null)
            tier_to_cool_after_days_since_last_access_time_greater_than    = try(base_blob.value.tier_to_cool_after_days_since_last_access_time_greater_than, null)
            tier_to_archive_after_days_since_modification_greater_than     = try(base_blob.value.tier_to_archive_after_days_since_modification_greater_than, null)
            tier_to_archive_after_days_since_last_access_time_greater_than = try(base_blob.value.tier_to_archive_after_days_since_last_access_time_greater_than, null)
            delete_after_days_since_modification_greater_than              = try(base_blob.value.delete_after_days_since_modification_greater_than, null)
            delete_after_days_since_last_access_time_greater_than          = try(base_blob.value.delete_after_days_since_last_access_time_greater_than, null)
            auto_tier_to_hot_from_cool_enabled                             = contains(keys(base_blob.value), "auto_tier_to_hot_from_cool_enabled") ? base_blob.value.auto_tier_to_hot_from_cool_enabled : null
            delete_after_days_since_creation_greater_than                  = try(base_blob.value.delete_after_days_since_creation_greater_than, null)
            tier_to_cold_after_days_since_creation_greater_than            = try(base_blob.value.tier_to_cold_after_days_since_creation_greater_than, null)
            tier_to_cool_after_days_since_creation_greater_than            = try(base_blob.value.tier_to_cool_after_days_since_creation_greater_than, null)
            tier_to_archive_after_days_since_creation_greater_than         = try(base_blob.value.tier_to_archive_after_days_since_creation_greater_than, null)
            tier_to_cold_after_days_since_modification_greater_than        = try(base_blob.value.tier_to_cold_after_days_since_modification_greater_than, null)
            tier_to_cold_after_days_since_last_access_time_greater_than    = try(base_blob.value.tier_to_cold_after_days_since_last_access_time_greater_than, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(base_blob.value.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
          }
        }

        dynamic "snapshot" {
          for_each = try(rule.value.actions.snapshot, {})

          content {
            change_tier_to_archive_after_days_since_creation               = try(snapshot.value.change_tier_to_archive_after_days_since_creation, null)
            change_tier_to_cool_after_days_since_creation                  = try(snapshot.value.change_tier_to_cool_after_days_since_creation, null)
            delete_after_days_since_creation_greater_than                  = try(snapshot.value.delete_after_days_since_creation_greater_than, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(snapshot.value.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
            tier_to_cold_after_days_since_creation_greater_than            = try(snapshot.value.tier_to_cold_after_days_since_creation_greater_than, null)
          }
        }

        dynamic "version" {
          for_each = try(rule.value.actions.version, {})

          content {
            change_tier_to_archive_after_days_since_creation               = try(version.value.change_tier_to_archive_after_days_since_creation, null)
            change_tier_to_cool_after_days_since_creation                  = try(version.value.change_tier_to_cool_after_days_since_creation, null)
            delete_after_days_since_creation                               = try(version.value.delete_after_days_since_creation, null)
            tier_to_cold_after_days_since_creation_greater_than            = try(version.value.tier_to_cold_after_days_since_creation_greater_than, null)
            tier_to_archive_after_days_since_last_tier_change_greater_than = try(version.value.tier_to_archive_after_days_since_last_tier_change_greater_than, null)
          }
        }
      }
    }
  }
  depends_on = [azurerm_storage_container.sc]
}

resource "azurerm_user_assigned_identity" "identity" {
  for_each = lookup(var.storage, "identity", null) != null ? (
    (lookup(var.storage.identity, "type", null) == "UserAssigned" ||
    lookup(var.storage.identity, "type", null) == "SystemAssigned, UserAssigned") &&
    lookup(var.storage.identity, "identity_ids", null) == null ? { "identity" = var.storage.identity } : {}
  ) : {}

  name                = try(each.value.name, "uai-${var.storage.name}")
  resource_group_name = var.storage.resource_group
  location            = var.storage.location
  tags                = try(each.value.tags, var.tags, null)
}

resource "azurerm_role_assignment" "managed_identity" {
  for_each = lookup(var.storage, "customer_managed_key", null) != null ? { "identity" = var.storage.customer_managed_key } : {}

  scope                = each.value.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.identity["identity"].principal_id
}

# advanced threat protection
resource "azurerm_advanced_threat_protection" "prot" {
  for_each = try(var.storage.threat_protection, false) ? { "threat_protection" = true } : {}

  target_resource_id = azurerm_storage_account.sa.id
  enabled            = true
}
