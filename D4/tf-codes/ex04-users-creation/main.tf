# -------------------------------
# Create 5 local vSphere users
# -------------------------------
# locals {
#   users = [
#     "harish",
#     "niranjan",
#     "amrutha",
#     "poovendan",
#     "ruban",
#     "asritha",
#     "yesaswini",
#     "sarika"
#   ]
# }

# Create users
# resource "vsphere_vcenter_sso_user" "local_users" {
#   #for_each   = toset(local.users)
#   domain     = "vsphere.local"
#   name       = each.key
#   given_name = upper(each.key)
#   family_name = "Admin"
#   email_address = "${each.key}@example.com"
#   password   = "Passw0rd@123"
# }

# resource "vsphere_vcenter_sso_user" "local_users" {
#   count     = length(var.usernames)
#   domain     = "vsphere.local"
#   name       = var.usernames[count.index]
#   label      =  upper(var.usernames[count.index])
#   given_name = upper(var.usernames[count.index])
#   family_name = "Admin"
#   email_address = "${var.usernames[count.index]}@example.com"
#   password   = "Passw0rd@123"
# }

# -------------------------------
# Assign Administrator role to each user
# -------------------------------
# Get root vCenter folder
# data "vsphere_folder" "root" {
#   path = "/"
# }

# # Fetch Administrator role
# data "vsphere_role" "administrator" {
#   label = "Administrator"
# }

# # Assign Administrator permissions
# resource "vsphere_permission" "admin_permission" {
#   for_each  = vsphere_vcenter_sso_user.local_users
#   principal = "vsphere.local\\${each.key}"
#   role_id   = data.vsphere_role.administrator.id
#   propagate = true
#   entity_id = data.vsphere_folder.root.id
# }

# # Assign Administrator permissions
# resource "vsphere_permission" "admin_permission" {
#   for_each  = vsphere_vcenter_sso_user.local_users
#   principal = "vsphere.local\\${each.key}"
#   role_id   = data.vsphere_role.administrator.id
#   propagate = true
#   entity_id = data.vsphere_folder.root.id
# }


resource "null_resource" "create_vcenter_users" {
  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ./userscript.ps1"
  }
}
