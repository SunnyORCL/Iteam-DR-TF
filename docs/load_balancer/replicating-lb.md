# Replicating Load Balancer

[[Sample Script]](/Terraform/sample_project/load_balancer.tf)

## Assumptions

Primary Region contains a VCN with 2 subnets and internet connectivity. One of the subnets contains a compute instance that will act as a backend server. The other subnet contains a load balancer and a load balancer specific security list allowing communication with the backend server. 

## Prerequisites 

- Load Balancer Networking has already been created [here](/docs/network/replicating_network.md#updates-for-load-balancer).
- Compute Instance has already been created [here](/docs/compute/compute.md#instancetf). 

## Updates to LOAD_BALANCER.TF

Four resources should have been exported: load_balancer, backend_set, listener, and backend. Only the backend will have to be updated. 

1. Update Backend Server's ip_address to use the new compute instance spun up.
    ```
    resource oci_load_balancer_backend backend1 {
        ip_address = oci_core_instance.<COMPUTE RESOURCE NAME>.private_ip
        ...
    }
    ```
