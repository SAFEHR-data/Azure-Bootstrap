#  Copyright (c) University College London Hospitals NHS Foundation Trust
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

resource "random_password" "gh_runner_vm" {
  length           = 32
  lower            = true
  min_lower        = 1
  upper            = true
  min_upper        = 1
  numeric          = true
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "_%@"
}

resource "azurerm_linux_virtual_machine_scale_set" "gh_runner" {
  name                  = "vm-gh-runner-${var.suffix}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2"
  instances             = 1
  network_interface_ids = [azurerm_network_interface.gh_runner_vm.id]

  admin_username = local.gh_runner_vm_username
  admin_password = random_password.gh_runner_vm.result

  disable_password_authentication = false

  custom_data = data.template_cloudinit_config.gh_runner_vm.rendered

  os_disk {
    disk_size_gb         = 128
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_network_interface" "gh_runnert_vm" {
  name                = "nic-gh-runner-vm-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ip-configuration-${var.suffix}"
    subnet_id                     = azurerm_subnet.bootstrap_shared.id
    private_ip_address_allocation = "Dynamic"
  }
}
