locals {
  cloudinit = templatefile("${path.module}/cloud-init.yaml", {
    ubuntu_password_hash = var.ubuntu_password_hash
    ssh_key              = var.ssh_key
  })
}

# Deploy VM from template
resource "vsphere_virtual_machine" "vm1" {
  count = length(var.vm-name)
  name             = "${var.vm-name[count.index]}-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8096
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
        host_name = var.vm-name[count.index]
        domain    = "vishwacloudlab.in"
      }

      network_interface {
        ipv4_address = var.ip-add[count.index]
        ipv4_netmask = 24


      }
      dns_server_list = ["8.8.8.8", "1.1.1.1"]
      ipv4_gateway = "157.119.43.1"
    }
  }
  extra_config = {
    "guestinfo.userdata"          = base64encode(local.cloudinit)
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata"          = base64encode("{}")
    "guestinfo.metadata.encoding" = "base64"
  }
  # Avoid hang
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
}

resource "null_resource" "common_install" {
  count = length(vsphere_virtual_machine.vm1)
  depends_on = [vsphere_virtual_machine.vm1]
  # SSH Connection
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    #host        = vsphere_virtual_machine.vm1[count.index].ipv4_address
    host        = var.ip-add[count.index]
    timeout     = "2m"
  }

  # Step 1: Common Setup
  provisioner "file" {
    source      = "scripts/init-common.sh"
    destination = "/tmp/init-common.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init-common.sh",
      "sudo /tmp/init-common.sh ${var.vm-name[count.index]}"
    ]
  }
}


resource "null_resource" "node_install" {
  count = length(vsphere_virtual_machine.vm1)
  depends_on = [null_resource.common_install]
  # SSH Connection
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    #host        = vsphere_virtual_machine.vm1[count.index].ipv4_address
    host        = var.ip-add[count.index]
    timeout     = "2m"
  }

  # Step 1: Common Setup
  provisioner "file" {
    source      = count.index == 0 ? "scripts/init-master.sh" : "scripts/init-worker.sh"
    destination = "/tmp/init-role.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init-role.sh",
      "sudo /tmp/init-role.sh"
    ]
  }
}