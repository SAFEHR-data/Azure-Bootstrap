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

resource "azurerm_virtual_network" "bootstrap" {
  name                = "vnet-bootstrap-${var.naming_suffix}"
  resource_group_name = azurerm_resource_group.bootstrap.name
  location            = azurerm_resource_group.bootstrap.location
  tags                = var.tags

  address_space = [
    var.use_random_address_space
    ? "10.${random_integer.ip[0].result}.${random_integer.ip[1].result}.0/24"
    : var.bootstrap_address_space
  ]
}

resource "azurerm_subnet" "shared" {
  name                 = "subnet-bootstrap-shared-${var.suffix}"
  resource_group_name  = azurerm_resource_group.bootstrap.name
  virtual_network_name = azurerm_virtual_network.bootstrap.name
  address_prefixes     = [local.bootstrap_shared_address_space]
}

resource "azurerm_private_dns_zone" "all" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "all" {
  for_each              = local.private_dns_zones
  name                  = "vnl-bootstrap-${each.key}-${var.suffix}"
  resource_group_name   = azurerm_resource_group.bootstrap.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.bootstrap.id

  depends_on = [
    azurerm_private_dns_zone.all
  ]
}

resource "azurerm_network_security_group" "bootstrap" {
  name                = "nsg-default-bootstrap-${var.suffix}"
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  security_rule {
    name                       = "deny-internet-outbound-override"
    description                = "Blocks outbound internet traffic unless an explicit outbound-allow rule exists. Overrides the default rule 65001"
    priority                   = 2000
    access                     = "Deny"
    protocol                   = "*"
    direction                  = "Outbound"
    destination_address_prefix = "Internet"
    destination_port_range     = 443
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_network_watcher_flow_log" "bootstrap" {
  count                     = var.network_watcher != null
  name                      = "nw-log-bootstrap-${var.suffix}"
  resource_group_name       = var.monitoring.network_watcher.resource_group_name
  network_watcher_name      = var.monitoring.network_watcher.name
  network_security_group_id = azurerm_network_security_group.bootstrap.id
  storage_account_id        = azurerm_storage_account.bootstrap.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.bootstrap.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.bootstrap.location
    workspace_resource_id = azurerm_log_analytics_workspace.bootstrap.id
    interval_in_minutes   = 10
  }

  lifecycle {
    precondition {
      condition     = !var.accesses_real_data || var.monitoring.network_watcher != null
      error_message = "Network watcher flow logs must be enabled with when accesses_real_data"
    }
  }
}
