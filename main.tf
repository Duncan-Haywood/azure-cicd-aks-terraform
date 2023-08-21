# main.tf
# Variables
variable "resource_group_name" {
  default = "my-k8s-rg"  
}

variable "location" {
  default = "East US"
}

variable "vnet_name" {
  default = "k8s-vnet"
}

variable "subnet_name" {
  default = "k8s-subnet"  
}

variable "cluster_name" {
  default = "k8s-cluster"
} 

variable "vm_size" {
  default = "Standard_B2s"
}

variable "node_count" {
  default = 1
}

provider "azurerm" {
  features {}
}


# Resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name 
  location = var.location
}

# Networking
resource "azurerm_virtual_network" "k8snet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "k8ssubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8snet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Kubernetes cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.k8s.location  
  resource_group_name = azurerm_resource_group.k8s.name

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size 
    vnet_subnet_id = azurerm_subnet.k8ssubnet.id
  }
}


# Outputs

output "resource_group_name" {
  value = azurerm_resource_group.k8s.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name 
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "kube_config_host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}