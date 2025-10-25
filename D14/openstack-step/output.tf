output "controller_info" {
  description = "Controller node information"
  value = {
    name              = vsphere_virtual_machine.controller.name
    id                = vsphere_virtual_machine.controller.id
    uuid              = vsphere_virtual_machine.controller.uuid
    configured_ip     = var.controller_ip
    default_ip        = try(vsphere_virtual_machine.controller.default_ip_address, "pending")
    guest_ip_addresses = try(vsphere_virtual_machine.controller.guest_ip_addresses, [])
  }
}

output "compute_info" {
  description = "Compute node information"
  value = {
    name              = vsphere_virtual_machine.compute.name
    id                = vsphere_virtual_machine.compute.id
    uuid              = vsphere_virtual_machine.compute.uuid
    configured_ip     = var.compute_ip
    default_ip        = try(vsphere_virtual_machine.compute.default_ip_address, "pending")
    guest_ip_addresses = try(vsphere_virtual_machine.compute.guest_ip_addresses, [])
  }
}

output "connection_info" {
  description = "SSH connection information"
  value = {
    controller_ssh = "ssh ${var.ssh_username}@${var.controller_ip}"
    compute_ssh    = "ssh ${var.ssh_username}@${var.compute_ip}"
    horizon_url    = "http://${var.controller_ip}/dashboard"
  }
}

output "next_steps" {
  description = "Next steps after deployment"
  sensitive = true
  value = <<-EOT
    
    ========================================================================
    OpenStack Deployment Complete!
    ========================================================================
    
    1. SSH to Controller:
       ssh ${var.ssh_username}@${var.controller_ip}
    
    2. Monitor DevStack installation:
       tail -f /opt/stack/logs/stack.sh.log
    
    3. Wait for installation to complete (30-60 minutes)
    
    4. Access Horizon Dashboard:
       URL: http://${var.controller_ip}/dashboard
       Username: admin
       Password: ${var.openstack_admin_password}
    
    5. Source OpenStack credentials:
       source /opt/stack/devstack/openrc admin admin
    
    6. Verify OpenStack services:
       openstack service list
       openstack hypervisor list
       openstack compute service list
    
    ========================================================================
  EOT
}
