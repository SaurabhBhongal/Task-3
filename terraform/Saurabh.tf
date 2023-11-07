provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "snipeit" {
  name     = "snipeit-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "snipeit_network" {
  name                = "snipeit-network"
  resource_group_name = azurerm_resource_group.snipeit.name
  location            = azurerm_resource_group.snipeit.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snipeit_subnet" {
  name                 = "snipeit-subnet"
  resource_group_name  = azurerm_resource_group.snipeit.name
  virtual_network_name = azurerm_virtual_network.snipeit_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "snipeit_nic" {
  name                = "snipeit-nic"
  location            = azurerm_resource_group.snipeit.location
  resource_group_name = azurerm_resource_group.snipeit.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snipeit_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "snipeit_vm" {
  name                  = "snipeit-vm"
  location              = azurerm_resource_group.snipeit.location
  resource_group_name   = azurerm_resource_group.snipeit.name
  network_interface_ids = [azurerm_network_interface.snipeit_nic.id]
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Password12345!"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


# Add any other resources or configurations needed for Snipe-IT.
