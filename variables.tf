variable "zone_name"{}

variable "zone_type" {
    default = "Primary"
}
variable "rrset_domain"{}

variable "rrset_rtype"{
    default ="A"
}
