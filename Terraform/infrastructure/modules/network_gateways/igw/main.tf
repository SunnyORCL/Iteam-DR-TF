resource "oci_core_internet_gateway" "internet_gateway" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = var.parent_vcn_id

    #Optional
    enabled = var.internet_gateway_enabled
    display_name = var.internet_gateway_display_name
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
}