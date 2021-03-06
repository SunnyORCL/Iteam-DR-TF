resource "oci_core_service_gateway" "service_gateway" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = var.vcn_id

    services {
        #Required
        service_id = var.service_id
    }

    #Optional
    display_name = var.service_gateway_display_name
    route_table_id = var.route_table_id
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
}