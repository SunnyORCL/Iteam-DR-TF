resource "oci_core_subnet" "subnet" {
    #Required
    cidr_block = var.subnet_cidr_block
    compartment_id = var.compartment_container_id
    vcn_id = var.vcn_container_id

    #Optional
    display_name = var.subnet_display_name
    dns_label = var.subnet_dns_label
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
    prohibit_public_ip_on_vnic = var.subnet_prohibit_public_ip_on_vnic
}