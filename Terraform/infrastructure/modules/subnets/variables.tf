variable "compartment_container_id" {}
variable "provisioned_by" {}
variable "vcn_container_id" {}

/* Subnet A Definition */
variable "subnet_cidr_block" {
    type = string
    default = ""
}

variable "subnet_dns_label" {
    type = string
    default = ""
}

variable "subnet_display_name" {
    type = string
    default = ""
}

variable "subnet_availability_domain" {
    type = string
    default = "regional"
}

variable "subnet_prohibit_public_ip_on_vnic" {
    type = bool
    default = false
}

variable "security_list_ids" {
    default = []
}

/* Shared Definitions */
variable "defined_tags" {
    type = map
    default = {}
}
variable "freeform_tags" {
    type = map
    default = {}
}