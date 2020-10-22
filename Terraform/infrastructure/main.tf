provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

module root_compartment {
  source = "./modules/compartments"
  compartment_id = "ocid1.compartment.oc1..aaaaaaaapyzngc24yswkwbn6443cmhfonlprcwxejigqzvo3mzksqzmemila"
  compartment_name = "MarkSmith"
  compartment_description = "MarkSmith"
}

module main_vcn {
  source = "./modules/vcns"
  vcn_cidr = "10.0.0.0/16"
  compartment_id = module.root_compartment.id
  vcn_display_name = "proactive-dr-vcn-20201022"
  vcn_dns_label = "pdrmainvcn"
  provisioned_by = var.provisioned_by
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": "norman.japheth.aberin@oracle.com"}
  freeform_tags = {"pdr-poc": "networks-vcn-main"}
}

module regional_subnet_a {
  source ="./modules/subnets"
  subnet_cidr_block = "10.0.1.0/24"
  compartment_container_id = module.root_compartment.id
  vcn_container_id = module.main_vcn.id
  subnet_display_name = "proactive-dr-subnet-20201022"
  subnet_dns_label = "pdrsubneta"
  provisioned_by = var.provisioned_by
  defined_tags = {"SE_Details.Resource_Purpose": "PoC", "SE_Details.SE_Email": "norman.japheth.aberin@oracle.com"}
  freeform_tags = {"pdr-poc": "networks-subnet-a"}
}