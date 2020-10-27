data oci_identity_availability_domains ads {
  compartment_id = var.compartment_id
}

data oci_core_subnet subnet {
    #Required
    subnet_id = var.subnet_id
}