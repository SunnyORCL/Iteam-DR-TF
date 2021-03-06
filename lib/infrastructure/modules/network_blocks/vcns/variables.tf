variable "compartment_id" {}

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

variable defined_tags { default = {} }
variable freeform_tags { default = {} }