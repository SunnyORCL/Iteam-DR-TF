# Step-by-Step guide on how to DR-enable your environment
**Summary**: If a large-scale outage affects your production applications, you need the ability to restore the workloads quickly. Your business continuity plan should include a DR strategy that meets your recovery point, recovery time, and budget objectives.

The following are the list of things to do to replicate your `primary` environment
1. _Discovery_ - Getting a usable terraform code
    - Assumption: Your compartment contains your entire environment and all the resources you are using.
2. _Replication_ - Recreating your current environment
3. _Connectivity_ - Ensuring proper failover


# Region-to-Region DR Enablement Steps and Goals
### 1. Discovery of Resources
```
./discovery/orm.md
```
**Goal**: To get the list of resources in the `primary` environment in Terraform (Infrastructure as Code) format, which we will then be updating manually and using to recreate the `standby` environment.