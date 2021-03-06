resource oci_core_vcn "vcn"{
  #Required
  cidr_block = var.vcn_cidr
  compartment_id = var.compartment_id
  #Optional
  display_name = var.vcn_display_name
  dns_label = var.vcn_dns_label
  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}