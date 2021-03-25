# I-Team Disaster Recovery Environment
 

## Goal

This script takes a primary region with a VCN + Subnets, App Server + tagged Block Volumes, and a VM Database and creates a basic DR environment. The DR will have a replicated VCN + Subnets, App Server (restored from boot volume) + Block Volume Backups, DB (from DataGuard), and a Load Balancer. 

## Components

provider.tf - Creates two providers to connect to OCI, one for the standby region (default) and one for the primary region.

vars.tf - Defines variables to be used throughout project.

availability_domain.tf - Initializes availability domain data sources.

core.tf - Creates networking components for the standby environment: VCN, Subnets for App Server/Load Balancer/DB + corresponding security Lists, Internet Gateway, Remote Peering Connection, Route table, DHCP Options.

compute.tf - Creates backup of the boot volume from the primary region's app server, copies it to the standby region, and spins up an instance from the boot volume. Oce app server is intialized, runs additional scripts from the compute to finish application set-up.

volume.tf - Creates volume group based on block volume tags and then assigns them a backup policy to the standby region.

database.tf - Create dataguard association for primary region DB to standby region.

load_balancer.tf - Creates a load balancer with the new app server as a backend.


## Setup after git clone

1. Open `terraform_scripts/basic_script/vars.tf` and fill in the correct values. 

2. Initialize backend state in `terraform_scripts/basic_script/provider.tf` (Optional). Needs a preauthenticated request URL to a file in Object storage.

3. From the OCI Console Primary Region, begin steps for Remote Peering Connection.
    - Create DRG
    - Attach to Primary VCN and add rule to route table where traffic to destination `STANDBY VCN CIDR` is routed to the `PRIMARY DRG`.
    - Add following rules to Primary DB's Security List to allow DB connections and communication with Standby DB's Subnet for DataGuard.
            
            Stateless: No;  Source : 0.0.0.0/0; IP Protocol: TCP;  Destination Port Range: 1521
            
            Stateless: No;  Source: <STANDBY SUBNET CIDR>;  IP Protocol: All Protocols
            

## Terraform Lifecycle
```
terraform init
terraform plan
terraform apply
```
