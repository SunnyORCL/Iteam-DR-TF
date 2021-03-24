
provider oci {
	region 				 = var.standby_region
	tenancy_ocid         = var.tenancy_id   
  	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

provider oci { 
  	alias                = "primary_region"
  	region               = var.primary_region
  	tenancy_ocid         = var.tenancy_id
	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

# terraform {
#   backend "http" {
#     address = "<Backend URL>"
# 	update_method = "PUT"
#   }
# }