

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

### PROVIDER.TF

Change the OCI Provider to include the identification information to be able to run terraform from the command line. Create a second OCI Provider to refer to the Primary region in the few instances where we need to pull data to connect the Disaster Recovery environment.
```
# OCI Provider for Standby Region (Default)
provider oci {
	region 		         = var.region
	tenancy_ocid         = var.tenancy_id   
  	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

# OCI Provider for Primary Region 
provider oci { 
  	alias                = "<ALIAS NAME>"          # use provider.<ALIAS NAME> when referencing a resource in this region
  	region               = var.primary_region
  	tenancy_ocid         = var.tenancy_id
	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}
```

### VARS.TF

Define variables to be used throughout project. Currently, only defining Provider.tf values and defining other values within the Resource blocks, but that is optional.
```
# OCI Provider Variables
variable region { default = "<STANDBY REGION>" }
variable primary_region { default = "<PRIMARY REGION NAME>" }
variable compartment_ocid { default = "<COMPARTMENT OCID" }

# OCI Identification Variables
variable api_fingerprint { default = "<API FINGERPRINT>" }
variable api_private_key_path { default =  "<PATH TO API PRIVATE KEY>" }
variable tenancy_id { default =  "<TENANCY OCID>" }
variable user_id { default =  "<USER OCID>" }

# Compute Variables
variable shape1 { default = "<config1>" }
variable shape2 { default =  "<config2>" }
```





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

    # Optional
    metadata = var.metadata
    fault_domain = var.fd_list[var.fd_number]
    display_name = var.instance_name
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags
    preserve_boot_volume = var.preserve_boot_volume

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


