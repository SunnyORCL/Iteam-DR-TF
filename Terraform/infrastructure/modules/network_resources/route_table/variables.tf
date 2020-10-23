variable compartment_id {}
variable parent_vcn_id {}
variable internet_gateway_id {}
variable defined_tags {}
variable freeform_tags {}

variable route_table_display_name {
    default = ""
}

variable route_table_route_rules_description {
    default = ""
}

variable route_table_route_rules_destination {
    default = "0.0.0.0/0"
}

variable route_table_route_rules_destination_type {
    default = "CIDR_BLOCK"
}