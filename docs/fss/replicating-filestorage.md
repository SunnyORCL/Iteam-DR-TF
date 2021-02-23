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

Declare the variables that will be referenced for the FSS configuration. Supply the IAM attributes and resource variables that will be used in the <i>variables.tf</i> file.
```
### IDENTITY VARIABLES

variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
```

### FSS

A new FSS will be created in a specified compartment and availability domain.
```
resource "oci_file_storage_file_system" "file_system" {
    #Required
    availability_domain = data.oci_identity_availability_domain.ad.name
    compartment_id = var.compartment_id

    #Optional
    display_name = var.fss_display_name
    defined_tags = <defined_tags>
    freeform_tags = <freeform_tags>
    kms_key_id = null
}
```

### MOUNT TARGET

The example below will create one mount target that will be associated with an existing subnet. A file system can be associated with multiple mount targets at a time, only if both exists in the same availability domain. 

```
resource "oci_file_storage_mount_target" "mount_target" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id = var.compartment_id
  subnet_id = var.subnet_id
  
  #Optional
  display_name = var.mt_display_name
  defined_tags = <defined_tags>
  freeform_tags = <freeform_tags>
  hostname_label = <hostname_labels> -- Hostname for the mount target's IP address
  ip_address = <private_ip> -- An available private IP in the subnet's CIDR
  nsg_ids = <nsg_ocids> -- Network Security Group OCIDs associated with the mount target. Maximum ID's = 5
}
```

### EXPORT

Create an export in a specific export set, export path, and file system. The <i>export_set_id</i> is supplied by the associated export set from the Mount Target creation and the <i>file_system_id</i> is supplied by the FSS creation at the beginning of this configuration.

```
### EXPORT 
resource "oci_file_storage_export" "fss_export" {
  export_set_id = oci_file_storage_mount_target.mount_target.export_set_id
  file_system_id = oci_file_storage_file_system.file_system.id
  path = var.export_path
}
```
### SNAPSHOT

<b>File Systems cannot be moved to a different availability domain or region.</b> This configuration creates a snapshot that can be copied using Oracle Tools such as <i>rsync</i>.

```
### FSS SNAPSHOT
resource "oci_file_storage_snapshot" "fss_snapshots" {
    #Required
    file_system_id = oci_file_storage_file_system.file_system.id
    name = var.snapshot_name
}
```
