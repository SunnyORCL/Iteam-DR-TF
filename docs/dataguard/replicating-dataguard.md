# Resource Stack Edits for Data Guard

## Assumptions

Primary Region contains a VCN, Subnet, Internet Gateway, with DB System running in Subnet. WORKING NOTE: Does it need an internet gateway?

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


## OCI Console Steps

1. Create a DB Security List to allow DB connections and communication with Standby DB's Subnet (take Subnet CIDR from New Variables). Assign to Primary DB's Subnet. (Step cannot be done in Terraform)

    Stateless: No       Source: <STANDBY VCN CIDR>      IP Protocol: All Protocols
    Stateless: No       Source : 0.0.0.0/0              IP Protocol: TCP                Destination Port Range: 1521

2. Download Resource Stack. Include availability_domain, core, database


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
```

### AVAILABILITY_DOMAIN.TF

Update data source availability domain from primary region to standby region. Create the correct number of Availability Domains (some regions have 1 and others have 3). https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
```
data oci_identity_availability_domain export_rLid-<STANDBY REGION NAME>-AD-1 {
    ...
}
```

### CORE.TF

1. Update resource oci_core_subnet from Primary Region's Subnet CIDR to Standby Region's Subnet CIDR.
    ```
    resource oci_core_subnet <SUBNET RESOURCE NAME> {
        cidr_block = "<STANDBY REGION'S SUBNET CIDR>"
        ...
    }
    ```

2. Update resource oci_core_vcn from Primary Region's VCN CIDR to Standby Region's VCN CIDR.
    ```
    resource oci_core_vcn <VCN RESOURCE NAME> {
        cidr_blocks = ["<STANDBY REGION'S VCN CIDR>",]
        ...
    }
    ```

3. Add DRG Route Rule in StandBy's Route Table to route traffic to Primary VCN. Should already include a rule to route traffic to internet gateway. DRG will be created in step 6.
    ```
    resource oci_core_default_route_table <ROUTE TABLE RESOURCE NAME> {
        route_rules {
            destination       = "<PRIMARY REGION'S VCN CIDR>"
            network_entity_id = oci_core_drg.<DRG RESOURCE NAME>.id
        }
        ...
    }
    ```

4. Comment out or Remove the Database Node resource type. This is automatically exported by OCI but a new Database Node will be created when the DB System is created. 
    ```
    /* resource oci_core_private_ip ... {
        ...
    } */
    ```

5. Update Security Lists

    Update Database Security List ingress rule's source to Primary Region's Subnet CIDR to allow for communication.
    ```
    resource oci_core_security_list <DATABASE SECURITY LIST RESOURCE NAME> {
        ingress_security_rules {
            source      = "<PRIMARY REGION'S SUBNET CIDR>"
            ...
        }
        ...
    }
    ```

    Update Default Security List ICMP ingress rule's source from Primary Region's VCN CIDR to Standby Region's VCN CIDR. 
    ```
    resource oci_core_default_security_list <DEFAULT SECURITY LIST RESOURCE NAME> {
        ingress_security_rules {
            icmp_options {
            code = "-1"
            type = "3"
            }
            protocol    = "1"
            source      = "<STANDBY REGION'S VCN CIDR>"
            source_type = "CIDR_BLOCK"
            stateless   = "false"
        }
        ...
    }
    ```

6. Create Remote Peering Connection for DataGuard

    Create DRG in Primary Region
    ```
    resource oci_core_drg primary_region_drg {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
        compartment_id = var.compartment_ocid
        display_name = "PrimaryRegionDRG"
    }

    resource oci_core_drg_attachment primary_region_drg_attachment {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
        drg_id = oci_core_drg.primary_region_drg.id
        vcn_id = "<PRIMARY REGION VCN OCID>"
    }
    ```

    Create DRG in Standby Region
    ```
    resource oci_core_drg standby_region_drg {
        compartment_id = var.compartment_ocid
        display_name = "StandbyRegionDRG"
    }

    resource oci_core_drg_attachment standby_region_drg_attachment {
        drg_id = oci_core_drg.<RESOURCE NAME of STANDBY REGION'S DRG (from above)>.id
        vcn_id = oci_core_vcn.<RESOURCE NAME OF STANDBY REGION'S VCN (above)>.id
    }
    ```

    Create Remote Peering Connection
    ```
    # Create Primary RPC
    resource oci_core_remote_peering_connection <PRIMARY RPC RESOURCE NAME> {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
        compartment_id = var.compartment_ocid
        drg_id = oci_core_drg.<PRIMARY DRG RESOURCE NAME>.id
        display_name = "<DISPLAY NAME>"  #Optional
    }

    # Create Standby RPC and Connect the RPCs
    resource oci_core_remote_peering_connection <STANDBY RPC RESOURCE NAME> {
        compartment_id = var.compartment_ocid
        drg_id = oci_core_drg.<STANDBY DRG RESOURCE NAME>.id
        display_name = "<DISPLAY NAME>" #Optional
        
        peer_id = oci_core_remote_peering_connection.<PRIMARY RPC RESOURCE NAME>.id
        peer_region_name = var.primary_region
    }
    ```

Before moving to next section, need to make sure that the Primary region has the appropriate route rule. We will make this change from the OCI Console but first need the DRG to be created.
1. Run the current terraform project (comment out all of database.tf)
2. Add rule in Primary Region's Default Route table where traffic to destination <PRIMARY VCN CIDR> is routed to the <PRIMARY DRG>

WORKING NOTE: Right now, do not want to update existing resources using terraform script. Would require an extra step of importing in configurations and then has the risk of a user performing terraform destroy and altering primary region. Specifically, need to edit existing Subnet in primary region to (1) Change Route Table to including routing Standby VCN Traffic to DRG and (2) Change Security List for Data Guard communication. Currently performing those two steps from the console.

### DATABASE.TF

1. Keep resource oci_database_db_system commented out. Some values will be used below to ensure backup DB is the exact same configuration.

2. Create DataGuard Association
    ```
    resource oci_database_data_guard_association test_data_guard_association {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>
        creation_type = "NewDbSystem" 
        database_id = "<PRIMARY DB OCID>"
        database_admin_password = "<PRIMARY DB PASSWORD>"
        delete_standby_db_home_on_delete = "true"
        protection_mode = "MAXIMUM_PERFORMANCE"
        transport_type = "ASYNC"

        #Required for creation_type = "NewDbSystem"
        display_name = "TanviStandby"
        shape  = "<Shape of original DB (look above)>"
        availability_domain = data.oci_identity_availability_domain.<AD FROM AVAILABILITY_DOMAIN.TF>.name
        subnet_id = oci_core_subnet.<SUBNET FROM CORE.TF>.id
        hostname = "<HOSTNAME>"

        #Required for creation_type = "ExistingDbSystem"
        #peer_db_home_id = data.oci_database_db_homes.db_homes_standby.id
        #peer_db_system_id = oci_database_db_system.<STANDBY DB NAME>.id
        #peer_vm_cluster_id = data.oci_database_db_homes.db_homes_standby.vm_cluster_id
    }
    ```

If DB type VM, creation_type must be "NewDbSystem" - cannot use existing. If DB type not VM, may be easier to spin up a new DB using provided code (i.e. skip step 1. above) and then use existing DB parameters. 
Data source to use existing DB from terraform script:
```
data "oci_database_db_homes" "db_homes_standby" {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.<STANDBY DB NAME>.id
}
```