terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.7.0"
    }
  }
}

provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "VMware1!VMware1!"
  vsphere_server = "vcenter01.vishwacloudlab.in"

  # Disable SSL verify if using self-signed certificate
  allow_unverified_ssl = true
}
