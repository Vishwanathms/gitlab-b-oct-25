# OpenStack Controller Node
resource "vsphere_virtual_machine" "controller" {
  name             = var.controller_name
  #resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder

  num_cpus                   = var.controller_cpus
  memory                     = var.controller_memory
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  firmware                   = data.vsphere_virtual_machine.template.firmware
  scsi_type                  = data.vsphere_virtual_machine.template.scsi_type
  wait_for_guest_net_timeout = 600
  wait_for_guest_ip_timeout  = 600

  # Network Interface - Management
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Network Interface - Provider/External
  network_interface {
    network_id   = data.vsphere_network.network_data.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Disk Configuration
  disk {
    label            = "disk0"
    size             = max(var.controller_disk_size, data.vsphere_virtual_machine.template.disks[0].size)
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
  }

  # Required for templates that use vApp/guestinfo (deliver via client CD-ROM)
  cdrom {
    client_device = true
  }

  # Clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Cloud-init configuration via vApp properties
  extra_config = {
    "guestinfo.metadata"          = base64encode(jsonencode({
      "local-hostname" = var.controller_name
      "instance-id"    = var.controller_name
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(local.controller_cloud_init)
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      annotation,
      clone[0].template_uuid,
      clone[0].customize,
    ]
  }
}

# OpenStack Compute Node
resource "vsphere_virtual_machine" "compute" {
  name             = var.compute_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder

  num_cpus                   = var.compute["cpus"]
  memory                     = var.compute["memory"]
  guest_id                   = data.vsphere_virtual_machine.template.guest_id
  firmware                   = data.vsphere_virtual_machine.template.firmware
  scsi_type                  = data.vsphere_virtual_machine.template.scsi_type
  wait_for_guest_net_timeout = 600
  wait_for_guest_ip_timeout  = 600

  # Enable nested virtualization
  nested_hv_enabled = true

  # CPU configuration for nested virtualization
  cpu_hot_add_enabled    = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true

  # Network Interface - Management
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Network Interface - Data/Tunnel
  network_interface {
    network_id   = data.vsphere_network.network_data.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Disk Configuration
  disk {
    label            = "disk0"
    size             = max(var.compute["disk"], data.vsphere_virtual_machine.template.disks[0].size)
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
  }

  # Required for templates that use vApp/guestinfo (deliver via client CD-ROM)
  cdrom {
    client_device = true
  }

  # Clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Cloud-init configuration via vApp properties
  extra_config = {
    "guestinfo.metadata"          = base64encode(jsonencode({
      "local-hostname" = var.compute_name
      "instance-id"    = var.compute_name
    }))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(local.compute_cloud_init)
    "guestinfo.userdata.encoding" = "base64"
    
    # Enable nested virtualization
    "vhv.enable"                           = "TRUE"
    "vcpu.hotadd"                          = "TRUE"
    "mem.hotadd"                           = "TRUE"
  }

  lifecycle {
    ignore_changes = [
      annotation,
      clone[0].template_uuid,
      clone[0].customize,
    ]
  }

  depends_on = [vsphere_virtual_machine.controller]
}
