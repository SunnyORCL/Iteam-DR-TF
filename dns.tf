#DNS Zone
resource "oci_dns_zone" "dns_zone" {
    #Required
    compartment_id = var.oci_compartment_id
    name = var.zone_name
    zone_type = var.zone_type
}

#DNS Records
resource "oci_dns_rrset" "dns_record" {
    #Required
    domain = var.rrset_domain
    rtype = var.rrset_type
    zone_name_or_id = oci_dns_zone.test_zone.id
}

