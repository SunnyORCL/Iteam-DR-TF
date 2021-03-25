resource "oci_core_drg" "drg" {
    #Required
    compartment_id = var.compartment_id

    #Optional
    display_name = var.drg_display_name
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
}