# Terraform Code Preparation

## Required Information

### Variables to pull from the OCI Console

- OCI Variables
    - Primary Region Name (ex: eu-amsterdam-1)
    - Standby Region Name
    - Compartment OCID 
- Identification Variables: This information allows the user to apply the terraform commands to create these resources from the terminal. If you would rather upload the terraform files directly to the OCI console, you do not need these values and do not need to update them in provider.tf or vars.tf
    - API fingerprint
    - api_private_key_path
    - Tenancy OCID
    - User OCID
            

## Terraform Updates

### VARS.TF

Define variables to be used throughout project. Currently, only defining basic values and defining other values within the Resource blocks, but that is optional.
```
# OCI Variables
variable region { default = "<STANDBY REGION>" }
variable primary_region { default = "<PRIMARY REGION NAME>" }
variable compartment_ocid { default = "<COMPARTMENT OCID" }

# OCI Identification Variables
variable api_fingerprint { default = "<API FINGERPRINT>" }
variable api_private_key_path { default =  "<PATH TO API PRIVATE KEY>" }
variable tenancy_id { default =  "<TENANCY OCID>" }
variable user_id { default =  "<USER OCID>" }
```

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

### Generic Changes

1. In the following sections, remove "Defined Tags" field exported with each resource, if present. They have been automatically marked with the time the resource was created which will not be accurate for the standby environment.

2. Change Resource Names and Display Names. This is optional. If you choose to change the resource names, be sure to change them throughout the files since the resources often refer to each other.