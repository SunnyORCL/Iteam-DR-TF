### PROVIDER.TF

Configure the provider for the Primary and Standby environments. The purpose of this module is to enable interaction with Oracle Cloud Infrastructure (OCI) services and supprted resources. Supply the appropriate authentication details as below:

```
### Primary Provider ###
provider "oci" {
	alias = "fss_primary"
	region = var.region
	tenancy_ocid = var.tenancy_ocid
	user_ocid = var.user_ocid
	fingerprint = var.fingerprint
	private_key_path = var.private_key_path
	
}

### DR Provider ###
provider "oci" {
    alias = "fss_dr"
    tenancy_ocid = var.dr.tenancy_ocid
    user_ocid = var.dr.user_ocid
    finger = var.dr_fingerprint
    private_key_path = var.dr_private_key_path
    region = var.dr_region
}

```
