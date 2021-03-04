# Replicating Database

[[Sample Script]](Terraform/sample_project/database.tf)

## Necessary Information

### Variables to pull from the OCI Console
             
- Primary Database OCID
- Primary Database Password
- Primary Database Shape (can also pull from downloaded terraform code)

## Updates to DATABASE.TF

1. Comment out resource oci_database_db_system. Some values will be used to ensure backup DB has the same configuration as the Primary DB..

2. Create DataGuard Association
    ```
    resource oci_database_data_guard_association test_data_guard_association {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>       # from provider.tf
        creation_type = "NewDbSystem" 
        database_id = "<PRIMARY DATABASE OCID>"
        database_admin_password = "<PRIMARY DB PASSWORD>"
        delete_standby_db_home_on_delete = "true"
        protection_mode = "MAXIMUM_PERFORMANCE"
        transport_type = "ASYNC"

        #Required for creation_type = "NewDbSystem"
        display_name = "TanviStandby"
        shape  = "<PRIMARY DATABASE SHAPE>"
        availability_domain = data.oci_identity_availability_domain.<AVAILABILITY DOMAIN RESOURCE NAME>.name        # from availability_domian.tf
        subnet_id = oci_core_subnet.<SUBNET RESOURCE NAME>.id        # from core.tf
        hostname = "<HOSTNAME>"         # to define

        #Required for creation_type = "ExistingDbSystem"
        #peer_db_home_id = data.oci_database_db_homes.db_homes_standby.id
        #peer_db_system_id = data.oci_database_db_homes.db_homes_standby.db_system_.id
    }
    ```

If DB type VM, creation_type must be "NewDbSystem". If DB type is not VM, we have the option to spin up a new Database using exported oci_database_db_system code (i.e. skip step 1 above) and then use existing DB parameters commented out above. If choosing this option, need to add in the following step before dataguard association:

Data source to use existing DB from terraform script:
```
data "oci_database_db_homes" "db_homes_standby" {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.<STANDBY DB RESOURCE NAME>.id
}
```
