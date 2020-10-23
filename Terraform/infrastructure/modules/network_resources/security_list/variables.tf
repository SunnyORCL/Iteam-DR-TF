variable "compartment_id" {}
variable "parent_vcn_id" {}
variable "defined_tags" {}
variable "freeform_tags" {}
variable "egress_rules" {}
variable "ingress_rules" {}

variable "display_name" {
    default = ""
}

locals {
  protocols = {
    icmp = "1"
    tcp  = "6"
    udp  = "17"
    all  = "all"
  }
}