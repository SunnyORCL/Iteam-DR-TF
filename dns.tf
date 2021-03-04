#DNS Zone
resource "oci_dns_zone" "dns_zone" {
    compartment_id = var.oci_compartment_id
    name = var.zone_type
    zone_type = var.zone_type
}

#DNS Record
resource "oci_dns_rrset" "dns_record" {
    domain = var.rrset_domain
    rtype = var.rrset_type
    zone_name_or_id = oci_dns_zone.test_zone.id
}