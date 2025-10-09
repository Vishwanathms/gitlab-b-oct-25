# Datacenter
data "vsphere_datacenter" "dc" {
  name = "Datacenter1"
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = "cluster1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Datastore
data "vsphere_datastore" "datastore" {
  name          = "nfs_main01-pub"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template
data "vsphere_virtual_machine" "template" {
<<<<<<< HEAD
  name          = "ubuntu-master"
=======
  name          = "ubuntu-noble-24.04-cloudimg"
>>>>>>> 0cda582444cc944a75ce79aad4bcb24e13eb5c32
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network
data "vsphere_network" "mgmt" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}