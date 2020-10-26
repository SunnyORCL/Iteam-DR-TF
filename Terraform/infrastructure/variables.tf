variable  "tenancy_ocid" {}
variable  "user_ocid" {}
variable  "fingerprint" {}
variable  "private_key_path" {}
variable  "region" {}

variable  "provisioned_by" {}
variable  "starting_parent_compartment" {}

locals {
  linux_latest = data.oci_core_images.linux_images.images[0].id
  windows2016  = data.oci_core_images.windows_images.images[0].id
}

data oci_core_images linux_images {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.8"
  filter {
    name   = "display_name"
    values = ["Oracle-Linux-[0-9].[0-9]{1,2}-[0-9]{4}.[0-9]{2}.[0-9]{2}"]
    regex  = true
  }
}

data oci_core_images windows_images {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Windows"
  operating_system_version = "Server 2016 Standard"
  filter {
    name   = "display_name"
    values = ["Windows-Server-2016-Standard-Edition-VM-Gen2-\\d{4}.*"]
    regex  = true
  }
}