locals {
  role_assignments = {
    "rbactestuser" = {
      upn  = "rbactestuser@bhavaniselvarajah299gmail.onmicrosoft.com" # Change to the test user's email
      type = "User"
      roles = {
        "Virtual Machine Contributor" = {
          scopes = {
            rg-test = azurerm_resource_group.test_rg.id
            vm-test = azurerm_linux_virtual_machine.test_vm.id
          }
        }
        "Storage Blob Data Reader" = {
          scopes = {
            storage-test = azurerm_storage_account.test_sa.id
          }
        }
      }
    }
  }
}
