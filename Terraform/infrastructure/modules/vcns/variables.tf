variable "compartment_id" {}
variable "provisioned_by" {}

/* VCN Definition */
variable "vcn_cidr" {
    type = string
    default = ""
}

variable "vcn_dns_label" {
    type = string
    default = ""
}

variable "vcn_display_name" {
    type = string
    default = ""
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