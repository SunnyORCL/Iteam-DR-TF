variable "compartment_container_id" {}
variable "vcn_container_id" {}

/* Subnet A Definition */
variable "subnet_cidr_block" {
    default = ""
}

variable "subnet_dns_label" {
    default = ""
}

variable "subnet_display_name" {
    default = ""
}

variable "subnet_availability_domain" {
    default = "regional"
}

variable "subnet_prohibit_public_ip_on_vnic" {
    default = false
}

variable "security_list_ids" {
    default = []
}

variable "route_table_id" {
    default = ""
}

variable defined_tags { default = {} }
variable freeform_tags { default = {} }