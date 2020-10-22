variable "main_compartment" {}
variable "provisioned_by" {}

/* VCN Definition */
variable "vcn_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vcn_dns_label" {
    type = string
    default = "prodrvcn"
}

variable "vcn_display_name" {
    type = string
    default = "proactive-dr-vcn-20201022"
}

/* Subnet A Definition */
variable "subnet_a_cidr_block" {
    type = string
    default = "10.0.1.0/24"
}

variable "subnet_dns_label" {
    type = string
    default = "prodrsubnet"
}

variable "subnet_a_display_name" {
    type = string
    default = "proactive-dr-subnet-20201022"
}

variable "subnet_availability_domain" {
    type = string
    default = "regional"
}

variable "subnet_prohibit_public_ip_on_vnic" {
    type = bool
    default = false
}

/* Shared Definitions */
locals { 
    defined_tags  = {
        "SE_Details.SE_Email" = var.provisioned_by 
        "SE_Details.Resource_Purpose" = "PoC"
    }
}

variable "freeform_tags" {
    type = map

    default = {
        "DR_POC" = "networks"
    }
}