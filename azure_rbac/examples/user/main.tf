provider "azurerm" {
  features {}
  subscription_id = "your sub id"
}
#testing with an example for role assignment for user with minimal cost(free tier eligible)
# Resource Group (Free Tier Eligible)
resource "azurerm_resource_group" "test_rg" {
  name     = "rbactest-rg"
  location = "East US"
}

# Virtual Network for VM (Free Tier Eligible)
resource "azurerm_virtual_network" "test_vnet" {
  name                = "rbactest-vnet"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for VM
resource "azurerm_subnet" "test_subnet" {
  name                 = "rbactest-subnet"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG) - Restricts SSH access within VNet
resource "azurerm_network_security_group" "test_nsg" {
  name                = "rbactest-nsg"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name

  security_rule {
    name                       = "AllowSSHFromVNet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16" # ✅ Allow only internal network
    destination_address_prefix = "*"
  }
}

# Network Interface (NIC) - No Public IP
resource "azurerm_network_interface" "test_nic" {
  name                = "rbactest-nic"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "test_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.test_nic.id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}

# Virtual Machine (Free Tier Eligible - Standard_B1s)
resource "azurerm_linux_virtual_machine" "test_vm" {
  name                = "rbactest-vm"
  location            = azurerm_resource_group.test_rg.location
  resource_group_name = azurerm_resource_group.test_rg.name
  size                = "Standard_B1s" # ✅ Free Tier Eligible

  admin_username                  = "azureuser"
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.test_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/(user)/.ssh/id_rsa.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # ✅ Free Tier Eligible
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Storage Account (Free Tier Eligible)
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "test_sa" {
  name                     = "rbactest${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.test_rg.name
  location                 = azurerm_resource_group.test_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Calling RBAC Module
module "rbac" {
  source           = "../../" # Ensure the RBAC module is in the correct path
  role_assignments = local.role_assignments
}
