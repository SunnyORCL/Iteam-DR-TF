<h1>Oracle Cloud Infrastructure (OCI) File Storage System Replication using Terraform</h1>

<h3>Assumptions</h3>

- The user has all IAM attributes
- The user is granted appropriate privileges to create resources in the environment

<h3>Dependencies</h3>

- VCN and Subnet resource is already created



<b>1</b1>. PROVIDER.TF

Configure the provider for the Primary and Standby environments. The purpose of this module is to enable interaction with Oracle Cloud Infrastructure (OCI) services and supported resources. Supply the appropriate authentication details as below:

```terraform
### Standby Environment ###
provider "oci" {
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    finger = var.fingerprint
    private_key_path = var.private_key_path
    region = var.region
}

```

<b>2</b>. TERRAFORM.TFVARS

Environmental variables are configured to be agnostic. Therefore, environment details will be defned in the .tfvars file. 

```terraform
#### DR/STANDBY TENANCY INFORMATION ####
tenancy_ocid = "<Standby Tenancy OCID>"
user_ocid = "<User OCID>"
compartment_id = "<Standby Compartment OCID>"
fingerprint = "<User API Fingerprint in Standby Environment>"
private_key_path = "<Private Key Path for the API Fingerprint Created in Standby Environment>"
region = "<Standby Region>"
```

<b>3</b>. VARIABLES.TF

Declare the variables that will be referenced for the FSS configuration. Supply the IAM attributes and resource variables that will be used in the <i>variables.tf</i> file.

```terraform
### IDENTITY VARIABLES

variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
```

<b>4</b>. DATA.TF
If required, change the availability domain number based on the subscribed standby region. New regions will only have one availability domain. 

```terraform
### List out the Availability Domains in OCI
data "oci_identity_availability_domain" "ad" {
    #Required
    compartment_id = var.tenancy_ocid
    ad_number = 1
}
```

<b>5</b4>. FSS

A new FSS will be created in a specified compartment and availability domain.
```terraform
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

<b>6</b>. MOUNT TARGET

The example below will create one mount target that will be associated with an existing subnet. A file system can be associated with multiple mount targets at a time, only if both exists in the same availability domain. 

```terraform
resource "oci_file_storage_mount_target" "mount_target" {
  #Required
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id = var.compartment_id
  subnet_id = var.subnet_id
  
  #Optional
  display_name = var.mt_display_name
  defined_tags = <defined_tags>
  freeform_tags = <freeform_tags>
  hostname_label = <hostname_labels>  /*Hostname for the mount target's IP address*/
  ip_address = <private_ip>  /*An available private IP in the subnet's CIDR*/
  nsg_ids = <nsg_ocids>  /*Network Security Group OCIDs associated with the mount target. Maximum ID's = 5*/
}
```

<b>7<b>. EXPORT

Create an export in a specific export set, export path, and file system. The <i>export_set_id</i> is supplied by the associated export set from the Mount Target creation and the <i>file_system_id</i> is supplied by the FSS creation at the beginning of this configuration. The FSS must have a minimum of one export in one mount target in order for instances to mount the file system.
```terraform
### EXPORT 
resource "oci_file_storage_export" "fss_export" {
  export_set_id = oci_file_storage_mount_target.mount_target.export_set_id
  file_system_id = oci_file_storage_file_system.file_system.id
  path = var.export_path
}
```
<b>8</b>. SNAPSHOT

<b>File Systems cannot be moved to a different availability domain or region.</b> This configuration creates a snapshot that can be copied to a different AD or region using Oracle Tools such as <i>rsync</i>.

```terraform
### FSS SNAPSHOT
resource "oci_file_storage_snapshot" "fss_snapshots" {
    #Required
    file_system_id = oci_file_storage_file_system.file_system.id
    name = var.snapshot_name
}
```
<b><i>OPTIONAL</i></b>
Export sets can be <i>managed</i> through terraform. The export set resource below allows the user to update file system attributes that are associated with the specified mount target.
```terraform
### EXPORT SET
resource "oci_file_storage_export_set" "exps_1" {
  # Required
  mount_target_id = oci_file_storage_mount_target.mount_target.id

  # Optional
  display_name = var.expset_name
  max_fs_stat_bytes = var.max_fss_byte
  max_fs_stat_files = var.max_fss_files
}
```
