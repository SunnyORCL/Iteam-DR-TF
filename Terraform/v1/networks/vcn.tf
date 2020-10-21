resource "oci_core_vcn" "dev_vcn_proactive" {
  #Required
  cidr_block = var.vcn_cidr
  compartment_id = var.main_compartment
  #Optional
  display_name = var.vcn_display_name
  dns_label = var.vcn_dns_label
  defined_tags = local.defined_tags
  freeform_tags = var.freeform_tags
}