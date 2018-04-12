## Provider

provider "azurerm" {
 subscription_id = "${var.subscription_id}"
 tenant_id = "${var.tenant_id}"
 client_id = "${var.client_id}"
 client_secret = "${var.client_secret}"
}

## Resource Group

data "azurerm_resource_group" "rg" {
  name = "${var.data_resource_group}"
}

## Security Group

resource "azurerm_network_security_group" "securitygroup" {
  name                = "SG-${var.vm_name}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
tags {
     Owner = "${var.owner_tag}"
    Business-Unit = "${var.business_unit_tag}"
  }
  security_rule {
    name                       = "All-TCP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

## Vnet

data "azurerm_virtual_network" "vnet" {
  name                 = "${var.data_vnet}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
}

## Subnet

data "azurerm_subnet" "subnet" {
  name                 = "${var.data_subnet}"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
}

## Public IP

resource "azurerm_public_ip" "eip" {
  name                         = "IP-${var.vm_name}"
  location                     = "${data.azurerm_resource_group.rg.location}"
  resource_group_name          = "${data.azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"

  tags {
    Owner = "${var.owner_tag}"
    Business-Unit = "${var.business_unit_tag}"
  }
}

## Network Interface

resource "azurerm_network_interface" "networkinterface" {
  name                = "NI-${var.vm_name}"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.securitygroup.id}"
  tags {
         Owner = "${var.owner_tag}"
    Business-Unit = "${var.business_unit_tag}"
    }
  ip_configuration {
    name                          = "Terraform"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.eip.id}"
    }
}


## Managed Disk

resource "azurerm_managed_disk" "disk" {
  name                 = "MD-${var.vm_name}"
  location             = "${data.azurerm_resource_group.rg.location}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.managed_disk_size}"
tags {
 Owner = "${var.owner_tag}"
    Business-Unit = "${var.business_unit_tag}"
}

}

## Linux VM

resource "azurerm_virtual_machine" "vm" {
  name                  = "VM-${var.vm_name}"
  location              = "${data.azurerm_resource_group.rg.location}"
  resource_group_name   = "${data.azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.networkinterface.id}"]
  vm_size               = "${var.vm_size}"

  
   delete_os_disk_on_termination = true
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "OD-${var.vm_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.disk.name}"
    managed_disk_id = "${azurerm_managed_disk.disk.id}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
     Owner = "${var.owner_tag}"
    Business-Unit = "${var.business_unit_tag}"
}

}
