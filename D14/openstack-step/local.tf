
# Local variables
locals {
  controller_cloud_init = templatefile("${path.module}/cloud-init-controller.yaml", {
    hostname               = var.controller_name
    ssh_username           = var.ssh_username
    ssh_public_key         = var.ssh_public_key
    controller_ip          = var.controller_ip
    compute_ip             = var.compute_ip
    network_gateway        = var.network_gateway
    network_netmask        = var.network_netmask
    dns_servers            = join(",", var.dns_servers)
    admin_password         = var.openstack_admin_password
    service_password       = var.openstack_service_password
    network_range          = var.openstack_network_range
    floating_range         = var.openstack_floating_range
  })

  compute_cloud_init = templatefile("${path.module}/cloud-init-compute.yaml", {
    hostname        = var.compute_name
    ssh_username    = var.ssh_username
    ssh_public_key  = var.ssh_public_key
    controller_ip   = var.controller_ip
    compute_ip      = var.compute_ip
    network_gateway = var.network_gateway
    network_netmask = var.network_netmask
    dns_servers     = join(",", var.dns_servers)
  })
}