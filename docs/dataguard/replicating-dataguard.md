# Resource Stack Edits for Data Guard

## Assumptions

## Necessary Information

### Variables to pull from the OCI Console

- Identification 
    - API fingerprint
    - api_private_key_path
    - Tenancy OCID
    - User OCID
    - Compartment OCID
- Primary Region
    - Region Name           = eu-amsterdam-1
    - VCN OCID              = ocid1.vcn.oc1.eu-amsterdam-1.amaaaaaantxkdlyaukqilsxaw4ctpnxztd45aafdsaq7iveithcthcf2dksa
    - VCN IP                = 10.0.0.0/16
    - Subnet IP             = 10.0.0.0/24
    - Database ocid         = ocid1.database.oc1.eu-amsterdam-1.abqw2ljroywchm2gjchk2mmftowjyavjd6wh4o4uat4772br6gfy2hqve7pq         

### New Variables

- Select Standby Region     
    - Standby Region Name   = uk-london-1
- Standby Region Networking
    - New VCN CIDR (has to be non-overlapping to Primary Region VCN)    = 10.1.0.0/16
    - New Subnet CIDR                                                   = 10.1.0.0/24

## Changes to make to .tf files

### Generic Changes
- Remove Defined Tags - marked with time created which will not be accurate
- Change Default Exported Resource Names

### PROVIDER.TF

```
provider oci {
	  region 				       = var.region
	  tenancy_ocid         = var.tenancy_id   
  	user_ocid            = var.user_id
  	fingerprint          = var.api_fingerprint
  	private_key_path     = var.api_private_key_path
}

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

```
variable region { default = "<STANDBY REGION>" }
variable primary_region { default = "<PRIMARY REGION NAME>" }
variable compartment_ocid { default = "ocid1.compartment.oc1..aaaaaaaab3yw6vwv6zafelbx6zvhuszn5iaoesrwxkh6d645arl266w4aofq" }

variable api_fingerprint { default = "3f:c2:66:ad:6b:95:9e:d4:2a:3b:a6:97:89:6d:bb:6e" }
variable api_private_key_path { default =  "/Users/tvaradha/.ssh/terraform_api_key.pem" }
variable tenancy_id { default =  "ocid1.tenancy.oc1..aaaaaaaaplkmid2untpzjcxrmbv4nowe74yb4lr6idtckwo4wyf7jh23be4q" }
variable user_id { default =  "ocid1.user.oc1..aaaaaaaa5in22b5bvkncp373g2mkhi6vh2cspj4vt2j5sx27576pql75umda" }
```

### AVAILABILITY_DOMAIN.TF

Update data source availability domain:
```
data oci_identity_availability_domain export_rLid-<STANDBY REGION NAME>-AD-1
```

### CORE.TF

Update resource oci_core_subnet
```
cidr_block = "<STANDBY REGION'S SUBNET CIDR>"
```

comment out the resource type oci_core_private_ip export_ocid1-dbnode-oc1...

Update resource oci_core_vcn
```
cidr_blocks = ["<STANDBY REGION'S VCN CIDR>",]
```
Update resource oci_core_default_security_list
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

Create Repote Peering Connection
```
resource "oci_core_remote_peering_connection" "dataguard_primary_rpc" {
    provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
    compartment_id = var.compartment_ocid
    drg_id = oci_core_drg.primary_region_drg.id
    display_name = "<DISPLAY NAME>"  #Optional
}

# Connecting Both Regions 

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
