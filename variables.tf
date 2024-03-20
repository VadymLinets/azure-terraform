variable "resource_groups_location" {
  type        = string
  description = "The Azure Region where the Resource Groups should exist. Changing this forces a new Resource Groups to be created."
  default     = "East US"
}

variable "vnet_address_space" {
  type        = string
  description = "The address space that is used the virtual network"
  default     = "10.4.0.0/16"
}

variable "aks_subnet" {
  type        = string
  description = "The address prefix to use for the aks node pool subnet."
  default     = "10.4.1.0/24"
}

variable "aks_windows_subnet" {
  type        = string
  description = "The address prefix to use for the aks node pool subnet."
  default     = "10.4.2.0/24"
}

variable "aks_identity_type" {
  type        = string
  description = "Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are SystemAssigned or UserAssigned."
  default     = "SystemAssigned"
}

variable "aks_network_plugin" {
  type        = string
  description = "Network plugin to use for networking. Currently supported values are azure, kubenet and none. Changing this forces a new resource to be created."
  default     = "azure"
}

variable "aks_network_policy" {
  type        = string
  description = "Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico, azure and cilium."
  default     = "calico"
}

variable "aks_load_balancer_sku" {
  type        = string
  description = "Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are basic and standard. Changing this forces a new resource to be created."
  default     = "standard"
}

variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Changing this forces a new resource to be created."
  default     = true
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as 1.22 are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in the documentation."
  default     = "1.27.9"
}

variable "aks_private_cluster_public_fqdn_enabled" {
  type        = bool
  description = "Specifies whether a Public FQDN for this Private Cluster should be added."
  default     = true
}

variable "aks_local_account_disabled" {
  type        = bool
  description = "If true local accounts will be disabled. See the documentation for more information."
  default     = false
}

variable "aks_sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium."
  default     = "Standard"
}

variable "aks_admins" {
  type        = list(string)
  description = "A list of Object IDs in Azure Active Directory which should have Admin Role on the Cluster."
}

variable "node_pull_os_sku" {
  type        = string
  description = "Specifies the OS SKU used by the agent pool. Possible values are AzureLinux, Ubuntu, Windows2019 and Windows2022. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated. temporary_name_for_rotation must be specified when attempting a change."
  default     = "Windows2022"
}

variable "node_pull_vm_size" {
  type        = string
  description = "The size of the Virtual Machine, such as Standard_DS2_v2. temporary_name_for_rotation must be specified when attempting a resize."
  default     = "Standard_D4s_v5"
}

variable "node_enable_auto_scaling" {
  type        = bool
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool?"
  default     = true
}

variable "node_min_count" {
  type        = number
  description = "The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  default     = 1
}

variable "node_max_count" {
  type        = number
  description = "The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  default     = 3
}

variable "node_max_pods" {
  type        = number
  description = "The maximum number of pods that can run on each agent. temporary_name_for_rotation must be specified when changing this property."
  default     = 30
}

variable "node_pool_zones" {
  type        = list(string)
  description = "Specifies a list of Availability Zones in which this Kubernetes Cluster Node Pool should be located. Changing this forces a new Kubernetes Cluster Node Pool to be created."
  default     = [1, 2, 3]
}

variable "acr_sku" {
  type        = string
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium."
  default     = "Standard"
}