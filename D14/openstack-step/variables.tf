# vSphere Connection Variables
variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server FQDN or IP"
  type        = string
}

variable "vsphere_allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = true
}

# vSphere Infrastructure Variables
variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "vsphere_cluster" {
  description = "vSphere cluster name"
  type        = string
}

variable "vsphere_datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "vsphere_network" {
  description = "vSphere network/portgroup name for management"
  type        = string
}

variable "vsphere_network_data" {
  description = "vSphere network/portgroup name for data/provider network"
  type        = string
  default     = ""  # Can be same as management network
}

variable "vsphere_template" {
  description = "Ubuntu 22.04 VM template name"
  type        = string
}

variable "vsphere_folder" {
  description = "VM folder path (optional)"
  type        = string
  default     = ""
}

# Controller Node Configuration
variable "controller_name" {
  description = "Controller node VM name"
  type        = string
  default     = "openstack-controller"
}

variable "controller_cpus" {
  description = "Number of vCPUs for controller"
  type        = number
  default     = 8
}

variable "controller_memory" {
  description = "Memory in MB for controller"
  type        = number
  default     = 16384  # 16 GB
}

variable "controller_disk_size" {
  description = "Disk size in GB for controller"
  type        = number
  default     = 100
}

variable "controller_ip" {
  description = "Static IP address for controller"
  type        = string
}

# Compute Node Configuration
variable "compute_name" {
  description = "Compute node VM name"
  type        = string
  default     = "openstack-compute"
}

variable "compute" {
  description = "Compute node sizing: use var.compute[\"cpus\"], var.compute[\"memory\"], var.compute[\"disk\"]"
  type = map(number)
  default = {
    cpus   = 6
    memory = 12288
    disk   = 100
  }
}

variable "compute_ip" {
  description = "Static IP address for compute node"
  type        = string
}

# Network Configuration
variable "network_gateway" {
  description = "Network gateway"
  type        = string
}

variable "network_netmask" {
  description = "Network netmask (e.g., 24 for /24)"
  type        = string
  default     = "24"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "dns_search_domain" {
  description = "DNS search domain"
  type        = string
  default     = "localdomain"
}

# OpenStack Configuration
variable "openstack_admin_password" {
  description = "OpenStack admin password"
  type        = string
  sensitive   = true
  default     = "openstack123"
}

variable "openstack_service_password" {
  description = "OpenStack service password"
  type        = string
  sensitive   = true
  default     = "service123"
}

variable "openstack_network_range" {
  description = "OpenStack internal network range (avoid conflicts)"
  type        = string
  default     = "10.254.0.0/24"
}

variable "openstack_floating_range" {
  description = "OpenStack floating IP range"
  type        = string
  default     = "192.168.100.0/24"
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for access"
  type        = string
}

variable "ssh_username" {
  description = "SSH username to create"
  type        = string
  default     = "ubuntu"
}
