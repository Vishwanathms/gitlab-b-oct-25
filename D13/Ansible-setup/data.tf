# Datacenter
data "vsphere_datacenter" "dc" {
  name = "Datacenter2"
}

# Cluster
# data "vsphere_compute_cluster" "cluster" {
#   name          = "cluster1"
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

# Datastore
data "vsphere_datastore" "datastore" {
  name          = "OS-DS"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu-jammy-22.04-cloudimg"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "mgmt" {
  #name          = "mgmt-pg"
  name = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}