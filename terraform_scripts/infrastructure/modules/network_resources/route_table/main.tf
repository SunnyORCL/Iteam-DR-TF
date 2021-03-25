resource "oci_core_route_table" "route_table" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = var.parent_vcn_id

    #Optional
    defined_tags = var.defined_tags
    display_name = var.route_table_display_name
    freeform_tags = var.freeform_tags

    route_rules {
        #Required
        network_entity_id = var.internet_gateway_id

        #Optional
        description = var.route_table_route_rules_description
        destination = var.route_table_route_rules_destination
        destination_type = var.route_table_route_rules_destination_type
    }
}