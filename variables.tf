variable "name"{
    default = "<fqdn.com>"
}
variable "zone_type" {
    default = "Primary"
}

variable "zone_name_or_id"{}

variable "rrset_domain" {}

variable "rrset_rtype"{
    default ="A"
}
