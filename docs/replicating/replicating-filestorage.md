### PROVIDER.TF

Configure the provider for the Primary and Standby environments. The purpose of this module is to enable interaction with Oracle Cloud Infrastructure (OCI) services and supported resources. Supply the appropriate authentication details as below:

```
### Primary Environment ###
provider "oci" {
	alias = "fss_primary"
	region = var.region
	tenancy_ocid = var.tenancy_ocid
	user_ocid = var.user_ocid
	fingerprint = var.fingerprint
	private_key_path = var.private_key_path
	
}

### DR Environment ###
provider "oci" {
    alias = "fss_dr"
    tenancy_ocid = var.dr.tenancy_ocid
    user_ocid = var.dr.user_ocid
    finger = var.dr_fingerprint
    private_key_path = var.dr_private_key_path
    region = var.dr_region
}

```

### TERRAFORM.TFVARS

Environmental variables are configured to be agnostic. Therefore, Primary and DR environment values will be defned in the .tfvars file. 

```
#### PRIMARY TENANCY INFORMATION ####
tenancy_ocid = "<Tenancy OCID>"
user_ocid = "<User OCID"
compartment_id = "<Compartment OCID>"
fingerprint = "<User API Fingerprint>"
private_key_path = "<Private Key Path for the API Fingerprint>"
region = "<Primary Region>"

#### DR/STANDBY TENANCY INFORMATION ####
dr_tenancy_ocid = "<Standby Tenancy OCID>"
dr_user_ocid = "<User OCID>"
dr_compartment_id = "<Standby Compartment OCID>"
dr_fingerprint = "<User API Fingerprint in Standby Environment>"
dr_private_key_path = "Private Key Path for the API Fingerprint Created in Standby Environment>"
dr_region = "<Standby Region>"
```
