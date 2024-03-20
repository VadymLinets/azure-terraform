terraform {
  required_version = ">= 1.6.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.78.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.host
  username               = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.username
  password               = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.password
  client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.host
    username               = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.username
    password               = azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.password
    client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
