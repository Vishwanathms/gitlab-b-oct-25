# Data Sources
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

# data "vsphere_compute_cluster" "cluster" {
#   name          = var.vsphere_cluster
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

data "vsphere_host" "host" {
  name          = "157.119.43.107"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}


data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network_data" {
  name          = var.vsphere_network_data != "" ? var.vsphere_network_data : var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}