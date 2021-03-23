# terraform {
#   backend "http" {
#     address = "https://objectstorage.us-sanjose-1.oraclecloud.com/p/iQgGsDD1dbxFcI1b60A_LsKS86-eJbaCV1HW0Ed-kNaKQef5iamYwVOzUs6sjw5n/n/orasenatdoracledigital01/b/terraform-backend/o/terraform.tfstate"
# 	update_method = "PUT"
#   }
# }


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