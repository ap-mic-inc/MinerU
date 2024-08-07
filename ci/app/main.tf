resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location

  lifecycle {
    prevent_destroy = true # Default is false
  }
}

# Create VM
resource "random_password" "vm" {
  length  = 20
  special = false
}

resource "azurerm_virtual_network" "app" {
  name                = "mineru-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "app" {
  name                 = "mineru-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "app" {
  name                = "mineru-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "app" {
  name                = "mineru-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                = "mineru-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_NC4as_T4_v3"
  depends_on          = [azurerm_network_interface.app]

  admin_username = "apmic"
  admin_password = random_password.vm.result

  network_interface_ids = [azurerm_network_interface.app.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "nvidia_hpc_sdk_vmi_23_03_0_gen2"
    product   = "nvidia_hpc_sdk_vmi"
    publisher = "nvidia"
  }

  source_image_reference {
    publisher = "nvidia"
    offer     = "nvidia_hpc_sdk_vmi"
    sku       = "nvidia_hpc_sdk_vmi_23_03_0_gen2"
    version   = "23.03.0"
  }

  disable_password_authentication = false
}

# Create Storage Account
resource "azurerm_storage_account" "caddy" {
  name                      = "stgofmineru"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}