# TO DO: CHANGE NUMBER OF AVAILABILITY DOMAINS BASED ON REGION

# CHANGE TO USING REGEX TO ACCESS ALL ADs WITH ONE DATA SOURCE

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
