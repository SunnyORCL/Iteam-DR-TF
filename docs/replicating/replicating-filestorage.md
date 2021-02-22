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

### VARIABLES.TF
Declare the variables that will be referenced in the FSS configuration.
```
### IDENTITY IN PRIMARY SITE ###

variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "ad" {
	default = "1"
}

### IDENTITY IN DR SITE ###
variable "dr_compartment_id" {}
variable "dr_tenancy_ocid" {}
variable "dr_user_ocid" {}
variable "dr_fingerprint" {}
variable "dr_private_key_path" {}
variable "dr_region" {}
variable "dr_ad" {
	default = "2"
}

### FSS ###
variable "fss_display_name" {
        default = "var.fss_display_name"
}

### MOUNT TARGET ###
variable "mount_target_name"{
        default = "var.mt_display_name"
}
```

### Create the File System
```
## Creates a FSS in the current enviornment ##
resource "oci_file_storage_file_system" "fss_primary" {
    #Required
    availability_domain = data.oci_identity_availability_domain.ad.name
    compartment_id = var.compartment_id
    
    #Optional
    display_name = var.fss_display_name
}

## Creates a secondary FSS in the Standby environment ##
resource "oci_file_storage_file_system" "fss_dr" {
    #Required
    availability_domain = var.dr_ad
    compartment_id = var.dr_compartment_id
    
    #Optional
    display_name = var.dr_fss_display_name
    defined_tags = null
    freeform_tags = null
    kms_key_id = null
}
