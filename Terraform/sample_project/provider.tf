provider oci {
	region 				 = var.region
	tenancy_ocid         = var.tenancy_id   
  	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

provider oci { 
  	alias                = "sanjose"
  	region               = var.primary_region
  	tenancy_ocid         = var.tenancy_id
	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}