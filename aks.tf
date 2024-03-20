resource "azurerm_resource_group" "aks_resource_group" {
  name     = "aks_resource_group"
  location = var.resource_groups_location
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks_subnet"
  resource_group_name  = azurerm_resource_group.virtual_network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_subnet]
}

resource "azurerm_subnet" "aks_windows_subnet" {
  name                 = "aks_windows_subnet"
  resource_group_name  = azurerm_resource_group.virtual_network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_windows_subnet]
}

resource "azurerm_network_security_group" "aks_network_security_group" {
  name                = "aks_network_security_group"
  location            = azurerm_resource_group.aks_resource_group.location
  resource_group_name = azurerm_resource_group.aks_resource_group.name

  security_rule {
    name                       = "deny_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_kubernetes_cluster.kubernetes_cluster]
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_network_security_group_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_network_security_group.id
}

resource "azurerm_subnet_network_security_group_association" "aks_windows_subnet_network_security_group_association" {
  subnet_id                 = azurerm_subnet.aks_windows_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_network_security_group.id
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                                = "kubernetes_cluster"
  location                            = azurerm_resource_group.aks_resource_group.location
  resource_group_name                 = azurerm_resource_group.aks_resource_group.name
  private_cluster_enabled             = var.aks_private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.aks_private_cluster_public_fqdn_enabled
  local_account_disabled              = var.aks_local_account_disabled
  sku_tier                            = var.aks_sku_tier
  dns_prefix                          = "aks"
  kubernetes_version                  = var.aks_kubernetes_version

  # NOTE: default node pool should be linux
  default_node_pool {
    name                        = "aksnodepool"
    vm_size                     = var.node_pull_vm_size
    vnet_subnet_id              = azurerm_subnet.aks_subnet.id
    enable_auto_scaling         = var.node_enable_auto_scaling
    min_count                   = var.node_min_count
    max_count                   = var.node_max_count
    max_pods                    = var.node_max_pods
    temporary_name_for_rotation = "askrotation"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = false
    admin_group_object_ids = var.aks_admins
  }

  network_profile {
    network_plugin    = var.aks_network_plugin
    network_policy    = var.aks_network_policy
    load_balancer_sku = var.aks_load_balancer_sku
  }

  identity {
    type = var.aks_identity_type
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows_node_pool" {
  name                  = "winnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  vm_size               = var.node_pull_vm_size
  mode                  = "User" # Note: must be set to `User` for windows
  os_type               = "Windows"
  os_sku                = var.node_pull_os_sku
  orchestrator_version  = var.aks_kubernetes_version
  enable_auto_scaling   = var.node_enable_auto_scaling
  min_count             = var.node_min_count
  max_count             = var.node_max_count
  max_pods              = var.node_max_pods
  vnet_subnet_id        = azurerm_subnet.aks_windows_subnet.id
}

resource "azurerm_container_registry" "acr" {
  name                = "vadimmmreg"
  resource_group_name = azurerm_resource_group.aks_resource_group.name
  location            = azurerm_resource_group.aks_resource_group.location
  sku                 = var.acr_sku
  admin_enabled       = true
}

data "azurerm_role_definition" "network_contributor_role" {
  name  = "Network Contributor"
  scope = data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "aks_network_contributor_role" {
  scope              = azurerm_subnet.aks_subnet.id
  role_definition_id = data.azurerm_role_definition.network_contributor_role.id
  principal_id       = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_windows_network_contributor_role" {
  scope              = azurerm_subnet.aks_windows_subnet.id
  role_definition_id = data.azurerm_role_definition.network_contributor_role.id
  principal_id       = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_identity_acr_pull_role" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
  skip_service_principal_aad_check = true
}

#data "kubectl_filename_list" "aks_manifests" {
#  depends_on = [azurerm_role_assignment.aks_identity_acr_pull_role, azurerm_kubernetes_cluster_node_pool.windows_node_pool]
#  pattern    = "./manifests/*.yaml"
#}
#
#resource "kubectl_manifest" "aks_manifest" {
#  depends_on = [data.kubectl_filename_list.aks_manifests]
#  for_each   = toset(data.kubectl_filename_list.aks_manifests.matches)
#  yaml_body  = file(each.value)
#}

resource "helm_release" "example" {
  name       = "my-local-chart"
  chart      = "./hello"

  values = [
    file("./hello/values.yaml")
  ]
}