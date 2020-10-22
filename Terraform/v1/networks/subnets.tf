resource "oci_core_subnet" "proactive_dr_subnet" {
    #Required
    cidr_block = var.subnet_a_cidr_block
    compartment_id = var.main_compartment
    vcn_id = oci_core_vcn.proactive_dr_vcn.id

    #Optional
    defined_tags = local.defined_tags
    display_name = var.subnet_a_display_name
    dns_label = var.subnet_dns_label
    freeform_tags = var.freeform_tags
    prohibit_public_ip_on_vnic = var.subnet_prohibit_public_ip_on_vnic
}