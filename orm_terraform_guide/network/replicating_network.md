# Replicating Networking

[[Sample Script]](/Terraform/sample_project/core.tf)

## Assumptions

Primary Region contains a VCN with a subnet and internet connectivity. The subnet contains a default security list.  

If there is a database, Primary Region contains a database residing in the subnet with an additional database specific subnet.

If there is a load balancer, the VCN contains an additional subnet. One of the subnets contains a compute instance that will act as a backend server. The other subnet contains a load balancer and a load balancer specific security list allowing communication with the backend server. 

## Necessary Information

### Variables to pull from the OCI Console
             
- Primary Region's VCN CIDR               
- Primary Region's Subnet CIDR   
- Primary Region's VCN OCID                 

### New Variables to Define

- Standby VCN CIDR (Note: has to be non-overlapping to Primary Region VCN to allow for Peering)
- Standby Subnet CIDR 
- Load Balancer Subnet CIDR (if Load Balancer present)


## Updates to AVAILABILITY_DOMAIN.TF

Update data source availability domain from primary region to standby region. Create the correct number of Availability Domains (some regions have 1 and others have 3). https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
```
data oci_identity_availability_domain export_rLid-<STANDBY REGION NAME>-AD-1 {
    ...
}
```

## Updates to CORE.TF

### Updates for Basic Replication

1. Update resource oci_core_subnet from Primary Region's Subnet CIDR to Standby Region's Subnet CIDR. Additionally, change variable dns_label to a unique value.
    ```
    resource oci_core_subnet <SUBNET RESOURCE NAME> {
        cidr_block = "<STANDBY REGION'S SUBNET CIDR>"
        ...
        dns_label = "<UNIQUE LABEL>"
    }
    ```


2. Update resource oci_core_vcn from Primary Region's VCN CIDR to Standby Region's VCN CIDR. Additionally, change variable dns_label to a unique value.
    ```
    resource oci_core_vcn <VCN RESOURCE NAME> {
        cidr_blocks = ["<STANDBY REGION'S VCN CIDR>",]
        ...
        dns_label = "<UNIQUE LABEL>"
    }
    ```

3. Update Default Security List ICMP ingress rule's source from Primary Region's VCN CIDR to Standby Region's VCN CIDR.
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

4. Comment out or Remove the Database Node resource type, if present. This is automatically exported by OCI but a new Database Node will be created when the DB System is created. 
    ```
    /* resource oci_core_private_ip ... {
        ...
    } */
    ```


### Updates for Database / Remote Peering Connection

5. Add DRG Route Rule in StandBy's Route Table to route traffic to Primary VCN. Should already include a rule to route traffic to internet gateway. DRG will be created in step 6.
    ```
    resource oci_core_default_route_table <ROUTE TABLE RESOURCE NAME> {
        route_rules {
            destination       = "<PRIMARY REGION'S VCN CIDR>"
            network_entity_id = oci_core_drg.<STANDBY DRG RESOURCE NAME>.id
        }
        ...
    }
    ```

6. Create Database Security List to allow connections to port 1521 and communication between Primary and Standby databases.

    Create Database Security List
    ```
    resource oci_core_security_list DB-Security-List {
        compartment_id = var.compartment_ocid
        display_name = "DB Security List"
        ingress_security_rules {
            description = "For Primary Peering"
            protocol    = "all"
            source      = "<PRIMARY REGION'S SUBNET CIDR>"
            source_type = "CIDR_BLOCK"
            stateless   = "false"
        }
        ingress_security_rules {
            description = "Connecting to DB"
            protocol    = "6"
            source      = "0.0.0.0/0"
            source_type = "CIDR_BLOCK"
            stateless   = "false"
            tcp_options {
                max = "1521"
                min = "1521"
            }
        }
        vcn_id = oci_core_vcn.<STANDBY VCN RESOURCE NAME>.id
    }
    ```

    Add DB Security List to Subnet's Resource Block.
    ```
    resource oci_core_subnet standbysubnet1 {
        ...
        security_list_ids = [
            oci_core_vcn.<STANDBY VCN RESOURCE NAME>.<DEFAULT SECURITY LIST RESOURCE NAME>.id,
            oci_core_security_list.<DATABASE SECURITY LIST RESOURCE NAME>.id,
        ]
    }
    ```
  
7. Create Remote Peering Connection for DataGuard

    Create DRG in Primary Region
    ```
    # Create Primary Region DRG
    resource oci_core_drg primary_region_drg {
        provider = oci.<PRIMARY REGION ALIAS NAME>          # from provider.tf
        compartment_id = var.compartment_ocid
        display_name = "PrimaryRegionDRG"
    }
    
    # Attach DRG to Primary VCN
    resource oci_core_drg_attachment primary_region_drg_attachment {
        provider = oci.<PRIMARY REGION ALIAS NAME>          # from provider.tf
        drg_id = oci_core_drg.primary_region_drg.id
        vcn_id = "<PRIMARY REGION VCN OCID>"
    }
    ```

    Create DRG in Standby Region
    ```
    # Create Standby Region DRG
    resource oci_core_drg standby_region_drg {
        compartment_id = var.compartment_ocid
        display_name = "StandbyRegionDRG"
    }
    
    # Attach DRG to Standby VCN
    resource oci_core_drg_attachment standby_region_drg_attachment {
        drg_id = oci_core_drg.<STANDBY DRG RESOURCE NAME>.id
        vcn_id = oci_core_vcn.<STANDBY VCN RESOURCE NAME>.id
    }
    ```

    Create Remote Peering Connection
    ```
    # Create Primary RPC
    resource oci_core_remote_peering_connection <PRIMARY RPC RESOURCE NAME> {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>           # from provider.tf
        compartment_id = var.compartment_ocid
        drg_id = oci_core_drg.<PRIMARY DRG RESOURCE NAME>.id
        display_name = "<DISPLAY NAME>"  #Optional
    }

    # Create Standby RPC and Connect the two RPCs
    resource oci_core_remote_peering_connection <STANDBY RPC RESOURCE NAME> {
        compartment_id = var.compartment_ocid
        drg_id = oci_core_drg.<STANDBY DRG RESOURCE NAME>.id
        display_name = "<DISPLAY NAME>" #Optional
        
        peer_id = oci_core_remote_peering_connection.<PRIMARY RPC RESOURCE NAME>.id
        peer_region_name = var.primary_region
    }
    ```

If creating a remote peering connection, then need to make sure that the Primary region has the appropriate route rule before moving to next section. We will make this change from the OCI Console but first need the DRG to be created.

        1. Comment out all of the other sections, then Run the current terraform project.

        2. Add rule in Primary Region's Default Route table where traffic to destination `STANDBY VCN CIDR` is routed to the `PRIMARY DRG`.

        3. Create a Database Security List in the Primary Region to allow DB connections and communication with Standby DB's Subnet. Assign to Primary DB's Subnet.

            Stateless: No;  Source: <STANDBY SUBNET CIDR>;  IP Protocol: All Protocols
            
            Stateless: No;  Source : 0.0.0.0/0; IP Protocol: TCP;  Destination Port Range: 1521


### Updates for Load Balancer

8. Update Load Balancer security list's egress rule to send traffic to the compute instance's subnet.
    ```
    resource oci_core_security_list LB-Security-List {
        ...
        egress_security_rules {
            destination      = <STANDBY SUBNET'S CIDR>
            ...
        }
    }
    ```

9. Update Load Balancer's Subnet CIDR to one in the standby region's VCN. Additionally, change variable dns_label to a unique value.
    ```
    resource oci_core_subnet lbSubnet {
        cidr_block     = "<LB SUBNET CIDR>"
        ...
        dns_label      = "<UNIQUE VALUE>"
        
    }
    ```