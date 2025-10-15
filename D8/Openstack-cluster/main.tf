locals {
  controller_cloudinit = templatefile("${path.module}/cloud-init/controller-cloudinit-v1.yaml", {
    #ubuntu_password_hash = var.ubuntu_password_hash
    ssh_key              = var.ssh_key
  })
  compute_cloudinit = templatefile("${path.module}/cloud-init/compute-cloudinit.yaml", {
    ssh_key = var.ssh_key
  })
}

# locals for cloud-init files
# data "local_file" "controller_userdata" {
#   filename = "${path.module}/cloud-init/controller-cloudinit.yaml"
# }

# data "local_file" "compute_userdata" {
#   filename = "${path.module}/cloud-init/compute-cloudinit.yaml"
# }

# Deploy VM from template
resource "vsphere_virtual_machine" "controller" {
  count = var.controller_vm.count
  name             = "${var.controller_vm.name}-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.controller_vm.cpus
  memory   = var.controller_vm.memory
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

    customize {
      linux_options {
        host_name = replace("${var.controller_vm.name}-${count.index + 1}", " ", "-")
        domain    = "vishwacloudlab.in"
      }

      network_interface {
        ipv4_address = var.controller_ip_add[count.index]
        ipv4_netmask = 24


      }
      dns_server_list = ["8.8.8.8", "1.1.1.1"]
      ipv4_gateway = "157.119.43.1"
    }
  }
  extra_config = {
    "guestinfo.userdata"          = base64encode(local.controller_cloudinit)
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata"          = base64encode("{}")
    "guestinfo.metadata.encoding" = "base64"
  }
  # Avoid hang
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}

# Create compute nodes
resource "vsphere_virtual_machine" "compute" {
  count            = var.compute_count
  name             = "openstack-compute-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.compute_cpus
  memory   = var.compute_memory
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

    customize {
      linux_options {
        host_name = "openstack-compute-${count.index + 1}"
        domain    = "vishwacloudlab.in"
      }

      network_interface {
        ipv4_address = var.compute_ip_add[count.index] # DHCP or set static
        ipv4_netmask = 24
      }
    }
  }

  extra_config = {
    "guestinfo.userdata"          = base64encode(local.compute_cloudinit)
    "guestinfo.userdata.encoding" = "base64"
  }
  # Avoid hang
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}

# Optionally wait for IPs from VMware guest tools (if open-vm-tools installed)
data "vsphere_virtual_machine" "controller_liv" {
  for_each = { for idx, vm in vsphere_virtual_machine.controller : idx => vm }
  name     = each.value.name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on = [vsphere_virtual_machine.controller]
}

data "vsphere_virtual_machine" "compute_liv" {
  for_each = { for idx, vm in vsphere_virtual_machine.compute : idx => vm }
  name     = each.value.name
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on = [vsphere_virtual_machine.compute]
}