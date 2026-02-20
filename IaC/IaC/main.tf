# Projeto 3 - Deploy do Stack de Infraestrutura de Dados no Azure com Terraform

# Define um grupo de recursos chamado "gp_virt_p3"
resource "azurerm_resource_group" "gp_virt_p3" {
  name     = "Grupo_Recursos_gp_virt_p3"
  location = "West US 2"
}

# Cria uma rede virtual chamada "p3_vnet"
resource "azurerm_virtual_network" "p3_vnet" {
  name                = "vnet_terr_p3"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gp_virt_p3.location
  resource_group_name = azurerm_resource_group.gp_virt_p3.name
}

# Cria a subnet dentro da rede virtual (os recursos de rede ficam na subnet)
resource "azurerm_subnet" "p3_subnet1" {
  name                 = "subnet_terr_p3"
  resource_group_name  = azurerm_resource_group.gp_virt_p3.name
  virtual_network_name = azurerm_virtual_network.p3_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# A principal diferença entre os dois ranges de ip acima é a escala da rede: 
# "10.0.0.0/16" é uma rede muito maior que abrange todos os endereços IP sob o "10.0.x.x", 
# enquanto "10.0.1.0/24" é uma sub-rede muito menor que inclui apenas os endereços sob "10.0.1.x".

# Cria uma interface de rede para a máquina virtual
resource "azurerm_network_interface" "p3_ni" {
  name                = "ni_terr_p3"
  location            = azurerm_resource_group.gp_virt_p3.location
  resource_group_name = azurerm_resource_group.gp_virt_p3.name

  # Configuração de IP para a interface de rede
  ip_configuration {
    name                          = "vm_p3"
    subnet_id                     = azurerm_subnet.p3_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Cria uma máquina virtual Linux
resource "azurerm_linux_virtual_machine" "p3_vm" {
  name                = "vm_linux_p3"
  resource_group_name = azurerm_resource_group.gp_virt_p3.name
  location            = azurerm_resource_group.gp_virt_p3.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  disable_password_authentication = false
  admin_password      = "mLMpVC1qqnoq795z"
  network_interface_ids = [azurerm_network_interface.p3_ni.id]

  # Configurações do disco para o sistema operacional
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Imagem do sistema operacional da máquina virtual
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}