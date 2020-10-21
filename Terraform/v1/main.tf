provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

module "networks" {
  source = "./networks"
  main_compartment = var.main_compartment
  provisioned_by = var.provisioned_by
}