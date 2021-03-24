# I-Team Disaster Recovery Environment
 

## Goal

This script takes a primary region with a VCN + Subnets, App Server + tagged Block Volumes, and a VM Database and creates a basic DR environment. The DR will have a replicated VCN + Subnets, App Server (restored from boot volume) + Block Volume Backups, DB (from DataGuard), and a Load Balancer. 


## Setup after git clone

1. Open `Terraform/basic_script/vars.tf` and fill in the correct values. 

2. Initialize backend state in `Terraform/basic_script/vars.tf`.

3. From the OCI Console Primary Region, begin steps for RPC.
    - Create DRG
    - Attach to VCN and add rule to route table
    - Add following rules to Security List to allow DB connections and communication with Standby DB's Subnet for DataGuard.
            Stateless: No;  Source : 0.0.0.0/0; IP Protocol: TCP;  Destination Port Range: 1521
            Stateless: No;  Source: <STANDBY SUBNET CIDR>;  IP Protocol: All Protocols
            

## Terraform Lifecycle
```
terraform init
terraform plan
terraform apply
```
