locals {
  cloudinit = [
    for idx, u in local.users : templatefile("${path.module}/cloud-init.yaml", {
      ssh_key  = u.ssh_key
      vm_name  = var.vm-name[0]
      username = u.name
    })
  ]
  users = [
    for u in var.users : {
      name    = u.name
      ssh_key = file(u.keyfile)
    }
  ]
}

# Deploy VM from template
resource "vsphere_virtual_machine" "vm1" {
  #count = length(var.vm-name)
  count = length(var.users)
  name             = "${var.users[count.index].name}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 3096
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

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # customize {
    #   linux_options {
    #     host_name = var.vm-name[count.index]
    #     domain    = "vishwacloudlab.in"
    #   }

    #   network_interface {
    #     ipv4_address = var.ip-add[count.index]
    #     ipv4_netmask = 24


    #   }
    #   dns_server_list = ["8.8.8.8", "1.1.1.1"]
    #   ipv4_gateway = "157.119.43.1"
    # }
  }
  extra_config = {
    "guestinfo.userdata"          = base64encode(local.cloudinit[count.index])
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata"          = base64encode("{}")
    "guestinfo.metadata.encoding" = "base64"
    #"guestinfo.ssh_public_key"   = local.users[count.index].ssh_key

  }
  # Avoid hang
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}
# output "vm_ips" {
#   value = [for vm in vsphere_virtual_machine.vm1 : vm.default_ip_address ]
# }

output "vm_ips" {
  value = zipmap(
    [for u in local.users : u.name],
    [for vm in vsphere_virtual_machine.vm1 : vm.default_ip_address]
  )
}
