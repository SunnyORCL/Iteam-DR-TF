resource "oci_core_instance" "instance" {
    #Required
    availability_domain = local.instance_availability_domain[var.ad]
    compartment_id = var.compartment_id
    shape = var.instance_shape
    metadata = var.metadata
    fault_domain = var.fd_list[var.fd_number]
    display_name = var.instance_name
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
    preserve_boot_volume = var.preserve_boot_volume

    create_vnic_details {
        #Optional
        assign_public_ip = var.is_public
        display_name = var.vnic_name
        hostname_label = var.hostname_label
        private_ip = var.private_ip
        subnet_id = var.subnet_id
        defined_tags = var.defined_tags
        freeform_tags = var.freeform_tags
    }

    source_details {
        #Required
        source_id = var.source_image
        source_type = "image"
    }
}
