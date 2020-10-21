variable "main_compartment" {}
variable "provisioned_by" {}


variable "vcn_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vcn_dns_label" {
    type = string
    default = "drvcnproactive"
}

variable "vcn_display_name" {
    type = string
    default = "dr-vcn-proactive-20201021"
}

variable "freeform_tags" {
    type = map

    default = {
        "DR_POC" = "networks"
    }
}

locals { 
    defined_tags  = {
        "SE_Details.SE_Email" = var.provisioned_by 
        "SE_Details.Resource_Purpose" = "PoC"
    }
}