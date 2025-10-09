terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.7.0"
    }
  }
}

provider "vsphere" {
  # user           = "administrator@vsphere.local"
  # password       = "VMware1!VMware1!"
  user = var.vcenter_user
  password = var.vcenter_password


  # Disable SSL verify if using self-signed certificate
  allow_unverified_ssl = true
}

terraform {
  backend "s3" {
    bucket = "vishwa11032025"
    key    = "terraform.tfstate"
    region = "us-east-1"
    # access_key = var.access_key
    # secret_key = var.secret_key

    # Uncomment below if you use DynamoDB for state locking
    # dynamodb_table = "your-lock-table"
    # encrypt = true
  }
}
