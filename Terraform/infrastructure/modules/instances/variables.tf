variable "compartment_id" {}
variable "subnet_id" {}
variable "instance_shape" {}
variable "instance_name" {}
variable "metadata" {}
variable "source_image" {}
variable "defined_tags" {}
variable "freeform_tags" {}
variable "vnic_name" {
    default = ""
}

variable "preserve_boot_volume" {
    default = false
}

variable "is_public" {
    default = true
}

variable "hostname_label" {
    default = ""
}

variable "private_ip" {
    default = ""
}

variable "ad" {
  default = "AD-1"
}

variable "fd_number" {
  default = 0
}

variable "fd_list" {
    default = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3"]
}

locals  {
    instance_availability_domain = {
        for ad in data.oci_identity_availability_domains.ads.availability_domains :
            regex("AD-\\d", ad.name) => ad.name
    }

    vnic_name = var.vnic_name == "" ? "${var.instance_name}_vnic" : var.vnic_name
}
