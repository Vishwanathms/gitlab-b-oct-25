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

<<<<<<< HEAD
    # customize {
    #   linux_options {
    #     host_name = var.vm-name
    #     domain    = "vishwacloudlab.in"
    #   }

    #   network_interface {
    #     ipv4_address = var.ip-add
    #     ipv4_netmask = 24
    #   }

    #   ipv4_gateway = "172.16.101.1"
    # }
  }
  # Avoid hang
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
=======
    customize {
      linux_options {
        host_name = var.vm-name
        domain    = "vishwacloudlab.in"
      }

      network_interface {
        ipv4_address = var.ip-add
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.101.1"
    }
  }
>>>>>>> 0cda582444cc944a75ce79aad4bcb24e13eb5c32
}

variable "vm-name" {}
variable "ip-add" {}
<<<<<<< HEAD
variable "vcenter_user" {}
variable "vcenter_password" {}
variable "access_key" {}
variable "secret_key" {}
# variable "dynamodb_table" {}

variable "env" {}
=======
>>>>>>> 0cda582444cc944a75ce79aad4bcb24e13eb5c32
