# Deploy VM from template
resource "vsphere_virtual_machine" "vm1" {
  name             = var.vm-name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.mgmt.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.vm-name
        domain    = "vishwacloudlab.in"
      }

      network_interface {
        ipv4_address = "172.16.101.50"
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.101.1"
    }
  }
}

variable "vm-name" {}