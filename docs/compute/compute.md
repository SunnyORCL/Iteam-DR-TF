

# Resource Stack Edits for Compute and Volume


## Necessary Information

### Variables to pull from the OCI Console

- Identification: This information allows the user to apply the terraform commands to create these resources from the terminal. If you would rather upload the terraform files directly to the OCI console, you do not need these values and do not need to update them in provider.tf or vars.tf
    - API fingerprint
    - api_private_key_path
    - Tenancy OCID
    - User OCID
    - Compartment OCID
- Primary Region
    - Region Name (ex: eu-amsterdam-1)
    - VCN OCID              
    - VCN IP                
    - Subnet IP                  

### New Variables

- Select Standby Region     
    - Standby Region Name 
- Standby Region Networking
    - Standby VCN CIDR (Note: has to be non-overlapping to Primary Region VCN to allow for Peering)
    - Standby Subnet CIDR 
 -    Instance Shape
      - needs to be defined for each compute shape                                              


## OCI Console Steps

 Download Resource Stack. Include availability_domain, core, and Instance modules.
 
## Changes to make to .tf files

### Generic Changes

1. Remove Defined Tags exported with each resource. They have been automatically marked with the time the resource was created which will not be accurate for the standby environment.

2. Change Resource Names and Display Names. This is optional. If you choose to change the resource names, be sure to change them throughout the files since the resources often refer to each other. 
WORKING NOTE: DO YOU MAYBE HAVE TO CHANGE THESE VALUES? IS KEEPING ALL THE VALUES THE SAME PERHAPS WHAT IS CAUSING MY DNSRECORD ERROR?







### INSTANCE.TF

Create Compute Instance

 Fill in variables for:
 - availability domain
 - compartment
 - instance name
 - instance shape

```
resource "oci_core_instance" "instance" {
    #Required
    availability_domain = local.instance_availability_domain[var.ad]
    compartment_id = var.compartment_id
    shape = var.instance_shape

    create_vnic_details {
        #Optional
        assign_public_ip = var.is_public
        display_name = var.vnic_name
        hostname_label = var.hostname_label
        private_ip = var.private_ip
        subnet_id = var.subnet_id
        defined_tags = var.defined_tags
        freeform_tags = var.freeform_tags
    }

    source_details {
        #Required
        source_id = var.source_image
        source_type = "image"
    }
   ```


### VOLUME.TF

Create Volumes for Compute

 Fill in variables for 
 - availability domain
 - compartment
 - volume name
 - (optional) size and backup policy

```hcl
resource "oci_core_volume" "test_volume" {
    #Required
    availability_domain = var.volume_availability_domain
    compartment_id = var.compartment_id

    #Optional
    backup_policy_id = data.oci_core_volume_backup_policies.test_volume_backup_policies.volume_backup_policies.0.id
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.volume_display_name
    freeform_tags = {"Department"= "Finance"}
    is_auto_tune_enabled = var.volume_is_auto_tune_enabled
    kms_key_id = oci_kms_key.test_key.id
    size_in_gbs = var.volume_size_in_gbs
    size_in_mbs = var.volume_size_in_mbs
    source_details {
        #Required
        id = var.volume_source_details_id
        type = var.volume_source_details_type
    }
    vpus_per_gb = var.volume_vpus_per_gb
}
```


