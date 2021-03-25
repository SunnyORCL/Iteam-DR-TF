resource "oci_core_nat_gateway" "nat_gateway" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = var.vcn_id

    #Optional
    block_traffic = var.nat_gateway_block_traffic
    defined_tags = var.defined_tags
    display_name = var.nat_gateway_display_name
    freeform_tags = var.freeform_tags
    public_ip_id = oci_core_public_ip.test_public_ip.id
}