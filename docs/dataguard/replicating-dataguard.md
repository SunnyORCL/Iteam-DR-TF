# Resource Stack Edits for Data Guard

## Assumptions

Primary Region contains a DB System and a VCN with a Security List to allow communication with the DB (ingress/egress on Port 1521).

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
    - Database OCID          

### New Variables

- Select Standby Region     
    - Standby Region Name 
- Standby Region Networking
    - New VCN CIDR (Note: has to be non-overlapping to Primary Region VCN to allow for Peering)
    - New Subnet CIDR                                                  

## Changes to make to .tf files

### Generic Changes

- Remove Defined Tags exported with each resource. They have been automatically marked with the time the resource was created which will not be accurate for the standby environment.
- Change Default Exported Resource Names. This is optional. If you choose to change the names, be sure to change them throughout the files since the resources often refer to each other. 

### PROVIDER.TF

Change the OCI Provider to include the identificaiton information to be able to run terraform from the command line. Create a second OCI Provider to refer to the Primary region in the few instances where we need to pull data to connect the Disaster Recovery environment.
```
# OCI Provider for Standby Region (Default)
provider oci {
	region 		     = var.region
	tenancy_ocid         = var.tenancy_id   
  	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

# OCI Provider for Primary Region 
provider oci { 
  	alias                = "<alias name here, for example the name of the region>"
  	region               = var.primary_region
  	tenancy_ocid         = var.tenancy_id
	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}
```

### VARS.TF

Define variables to be used throughout project. Currently, only defining Provider.tf values and defining other values within the Resource creation but that is optional.
```
# OCI Provider Variables
variable region { default = "<STANDBY REGION>" }
variable primary_region { default = "<PRIMARY REGION NAME>" }
variable compartment_ocid { default = "ocid1.compartment.oc1..aaaaaaaab3yw6vwv6zafelbx6zvhuszn5iaoesrwxkh6d645arl266w4aofq" }

# OCI Identification Variables
variable api_fingerprint { default = "3f:c2:66:ad:6b:95:9e:d4:2a:3b:a6:97:89:6d:bb:6e" }
variable api_private_key_path { default =  "/Users/tvaradha/.ssh/terraform_api_key.pem" }
variable tenancy_id { default =  "ocid1.tenancy.oc1..aaaaaaaaplkmid2untpzjcxrmbv4nowe74yb4lr6idtckwo4wyf7jh23be4q" }
variable user_id { default =  "ocid1.user.oc1..aaaaaaaa5in22b5bvkncp373g2mkhi6vh2cspj4vt2j5sx27576pql75umda" }
```

### AVAILABILITY_DOMAIN.TF

Update data source availability domain from primary region to standby region. Create the correct number of Availability Domains (some regions have 1 and others have 3). 
```
data oci_identity_availability_domain export_rLid-<STANDBY REGION NAME>-AD-1
```

### CORE.TF

Update resource oci_core_subnet from Primary Region's Subnet CIDR to Standby Region's Subnet CIDR.
```
cidr_block = "<STANDBY REGION'S SUBNET CIDR>"
```

Comment out the resource type **oci_core_private_ip export_ocid1-dbnode-oc1...**

Update resource oci_core_vcn from Primary Region's VCN CIDR to Standby Region's VCN CIDR.
```
cidr_blocks = ["<STANDBY REGION'S VCN CIDR>",]
```

Update resource oci_core_default_security_list from Primary Region's VCN Name to Standby Region's VCN Name. Change egress rule's destination and ingress rule's source to Primary Region's VCN CIDR to allow for communication. 
```
vcn_id = oci_core_vcn.<NAME OF STANDBY REGION'S VCN (above)>.id
...
egress_security_rules {
    destination      = "<PRIMARY REGION'S VCN CIDR>"
    ...
}
ingress_security_rules {
    source      = "<PRIMARY REGION'S VCN CIDR>"
    ...
}
```

Create DRG in Standby Region
```
resource "oci_core_drg" "standby_region_drg" {
    compartment_id = var.compartment_ocid
    display_name = "StandbyRegionDRG"
}

resource "oci_core_drg_attachment" "standby_region_drg_attachment" {
    drg_id = oci_core_drg.standby_region_drg.id
    vcn_id = oci_core_vcn.<NAME OF STANDBY REGION'S VCN (above)>.id
}
```

Create DRG in Primary Region
```
resource "oci_core_drg" "primary_region_drg" {
    provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
    compartment_id = var.compartment_ocid
    display_name = "PrimaryRegionDRG"
}

resource "oci_core_drg_attachment" "primary_region_drg_attachment" {
    provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
    drg_id = oci_core_drg.primary_region_drg.id
    vcn_id = "<PRIMARY REGION VCN OCID>"
}
```

Create Remote Peering Connection
```
# Create Primary RPC
resource "oci_core_remote_peering_connection" "dataguard_primary_rpc" {
    provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
    compartment_id = var.compartment_ocid
    drg_id = oci_core_drg.primary_region_drg.id
    display_name = "<DISPLAY NAME>"  #Optional
}

# Create Standby RPC and Connect the RPCs
resource "oci_core_remote_peering_connection" "dataguard_standby_rpc" {
    compartment_id = var.compartment_ocid
    drg_id = oci_core_drg.standby_region_drg.id
    display_name = "<DISPLAY NAME>" #Optional
    peer_id = oci_core_remote_peering_connection.dataguard_primary_rpc.id
    peer_region_name = var.primary_region
}
```

### DATABASE.TF

If DB type VM, have to create a new DB system. Cannot use existing. So comment out resource oci_database_db_system (but some values will be used below to ensure backup DB is the exact same configuration)

If DB type not VM, may be easier to spin up a new DB using provided code and then use existing DB parameters. 
Data source to use existing DB:
```
data "oci_database_db_homes" "db_homes_standby" {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.<STANDBY DB NAME>.id
}
```

Create DataGuard Association
```
data "oci_database_database" "primary_existing_db" {
    provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
    database_id = "<PRIMARY DB OCID>"
}

resource "oci_database_data_guard_association" "test_data_guard_association" {
    creation_type = "NewDbSystem" 
    database_id = data.oci_database_database.primary_existing_db.id
    database_admin_password = "<PrimaryDBPassword (must be the same)>"
    delete_standby_db_home_on_delete = "true"
    protection_mode = "MAXIMUM_PERFORMANCE"
    transport_type = "ASYNC"

    #Required for NewDbSystem
    display_name = "TanviStandby"
    shape  = "<Shape of original DB (look above)>"
    availability_domain = data.oci_identity_availability_domain.<AD from availability_domain.tf>.name
    subnet_id = oci_core_subnet.<Subnet from Core.tf>.id
    hostname = "<hostname>"
    
    #Required for ExistingDbSystem: not possible for VM type DB
    peer_db_home_id = data.oci_database_db_homes.db_homes_standby.id
    peer_db_system_id = oci_database_db_system.<STANDBY DB NAME>.id
    peer_vm_cluster_id = data.oci_database_db_homes.db_homes_standby.vm_cluster_id

}
```
