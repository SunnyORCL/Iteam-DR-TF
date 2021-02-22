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
	default = ""
}

### IDENTITY IN DR SITE ###
variable "dr_compartment_id" {}
variable "dr_tenancy_ocid" {}
variable "dr_user_ocid" {}
variable "dr_fingerprint" {}
variable "dr_private_key_path" {}
variable "dr_region" {}
variable "dr_ad" {
	default = ""
}

### FSS ###
variable "fss_display_name" {
        default = "var.dr_fss_display_name"
}

### MOUNT TARGET ###
variable "mount_target_name"{
        default = "var.dr_mt_display_name"
}
```

### Create the File System
```
## Creates a secondary FSS in the Standby environment ##
resource "oci_file_storage_file_system" "fss_dr" {
    #Required
    availability_domain = data.oci_identity_availability_domain.ad.name
    compartment_id = var.dr_compartment_id
    
    #Optional
    display_name = var.dr_fss_display_name
}
```
### Create the Mount Target
```
resource "oci_file_storage_mount_target" "dr_mount_target" {
    #Required
    availability_domain = data.oci_identity_availability_domain.ad.name
    compartment_id = var.dr_compartment_id
    subnet_id = oci_core_subnet.dr_subnet_id

    #Optional
    display_name = var.dr_mt_display_name
}
```
### Create the Export for FSS
```
```

### DATA.TF
Update the availability domain number for your standby region.

```
data "oci_identity_availability_domain" "ad" {
    #Required
    compartment_id = var.tenancy_ocid
    ad_number = 1
}
```

