/* This script initializes availability domain data sources to be used throughout modules. */


data oci_identity_availability_domain AD-1 {
  compartment_id = var.compartment_ocid
  ad_number      = "1"
}

# data oci_identity_availability_domain AD-2 {
#   compartment_id = var.compartment_ocid
#   ad_number      = "2"
# }

# data oci_identity_availability_domain AD-3 {
#   compartment_id = var.compartment_ocid
#   ad_number      = "3"
# }
