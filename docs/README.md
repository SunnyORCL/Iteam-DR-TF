# Step-by-Step guide on how to DR-enable your environment
**Summary**: If a large-scale outage affects your production applications, you need the ability to restore the workloads quickly. Your business continuity plan should include a DR strategy that meets your recovery point, recovery time, and budget objectives.

The following are the list of things to do to replicate your `primary` environment
1. _Discovery_ - Getting a usable terraform code
    - Assumption: Your compartment contains your entire environment and all the resources you are using.
2. _Replication_ - Recreating your current environment
3. _Connectivity_ - Ensuring proper failover


# Region-to-Region DR Enablement Steps and Goals
## Discovery
### 1. Resource Discovery with ORM

__Goal__: To get the list of resources in the `primary` environment in Terraform (Infrastructure as Code) format, which we will then be updating manually and using to recreate the `standby` environment.

[[Go To Guide]](./discovery/orm.md)

## Replication
### 2. Terraform Code Preparation

__Goal__: To get `primary` environment variables that will be used for the rest of the steps and update the included `provider.tf` and `vars.tf` .

[[Go To Guide]](./network/replication.md)

### 3. Establishing Network Connectivity

**Goal**: To replicate `primary` network components into another region, to where the `standby` environment will be. These network components will be used by all other components including `primary` environment Load Balancers relying on networking and is therefore critical and sensitive.

[[Go To Guide]](./replication_prep/terraform_prep.md)


### 4. Replicating Compute [If Exists]

[[Go To Guide]](./compute/compute.md)

### 5. Replicating Volumes [If Exists]
[[Go To Guide]](./compute/compute.md)

### 6. Replicating Databases [If Exists]
[[Go To Guide]](./dataguard/replicating-dataguard.md)

### 7. Replicating Object Storage [If Exists]
**Goal**: To replicate your Object Storage buckets from one region to another as well as establish object storage replication policies that will maintain multiple copies of data in your `primary` region to your `standby` region.


[[Go To Guide]](./object_storage/replication.md)


### 8. Replicating File Storage [If Exists]
[[Go To Guide]](./fss/replicating-filestorage.md)


## Connectivity
### 9. Ensuring Availability with DNS
**Goal**: Use DNS steering management to redirect client traffic to the current production region after a failover.

[[Go To Guide]](./dns/connectivity.md)

### 9. Clean Up
