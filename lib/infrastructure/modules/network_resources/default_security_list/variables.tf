variable "resource_id" {}
variable "egress_rules" {}
variable "ingress_rules" {}

locals {
  protocols = {
    icmp = "1"
    tcp  = "6"
    udp  = "17"
    all  = "all"
  }
}