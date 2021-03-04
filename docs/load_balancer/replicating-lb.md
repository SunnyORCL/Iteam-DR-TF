# Replicating Load Balancer

[[Sample Script]](Terraform/sample_project/load_balancer.tf)

## Assumptions

Primary Region contains a VCN with 2 subnets and internet connectivity. One of the subnets contains a compute instance that will act as a backend server. The other subnet contains a load balancer and a load balancer specific security list allowing communication with the backend server. 

## Necessary Information

### Variables to pull from the OCI Console
             
- Primary Region's VCN CIDR               
- Primary Region's Subnet CIDR   
- Primary Region's VCN OCID                 

### New Variables to Define

- Load Balancer Subnet CIDR 

## Updates to CORE.TF

1. Update Load Balancer security list's egress rule to send traffic to the compute instance's subnet.
    ```
    resource oci_core_security_list LB-Security-List {
        ...
        egress_security_rules {
            destination      = <STANDBY SUBNET'S CIDR>          # from core.tf
            ...
        }
    }

2. Update Load Balancer's Subnet CIDR to one in the standby region's VCN. Additionally, change variable dns_label to a unique value.
    ```
    resource oci_core_subnet lbSubnet {
        cidr_block     = "<LB SUBNET CIDR>"
        ...
        dns_label      = "<UNIQUE VALUE>"
        
    }

## Updates to LOAD_BALANCER.TF

1. Update Backend Server's ip_address to use the new compute instance spun up.
    ```
    resource oci_load_balancer_backend backend1 {
        ip_address = oci_core_instance.<COMPUTE RESOURCE NAME>.private_ip
        ...
    }
    ```