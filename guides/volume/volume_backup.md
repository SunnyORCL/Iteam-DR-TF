# Replicating Block Volumes

**Goal**: To back-up your Block Volumes to maintain multiple copies of data in your `primary` region as well as your `standby` region.

[[Sample Script]](/Terraform/sample_project/volume.tf)

## Necessary Information

### Variables to pull from the OCI Console
                  
- Primary Region Availability Domain (ex: rLid:US-SANJOSE-1-AD-1)
- Optional: OCIDs of Block Volumes (May not be required. Check Step #2.)            

## Updates to CORE.TF

1. Create cross-regional back-up policy. This resource will be based in the primary region but references our standby region. Replace `schedules` block with desired backup policy. In sample code below,have defined a monthly backup frequency.

    ```
    # CREATE BACKUP POLICY AND FILTER TAGGED VOLUMES

    resource oci_core_volume_backup_policy block_backup_policy {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>       # from provider.tf
        compartment_id = var.compartment_id
        destination_region = var.region
        display_name = "block_backup_policy"
        schedules {                                       # Replace with required schedule. https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_backup_policy
            backup_type       = "FULL"
            day_of_month      = "1"
            day_of_week       = "MONDAY"
            hour_of_day       = "0"
            month             = "JANUARY"
            offset_seconds    = "0"
            offset_type       = "STRUCTURED"
            period            = "ONE_MONTH"
            retention_seconds = "2678400"
            time_zone         = "UTC"
        }
    }
    ```


2. Select the volumes to be included in the volume group to be backed up. To choose these volumes, you have two options: 
        
      1. You can either pull the list of volumes as a data source. This will be the best solution if all of the volumes in the specified compartment need to be included in the backup OR if all the required volumes can be easily filtered by a tag or by a ----

      2. You can go into the OCI console and find the OCIDs of all the block volumes to be backed up. This will be the best solution if only a subset of the volumes need to be backed up or cannot be easily filtered. 

    If you choose to use solution one, add the data source below to your code. If backing up ALL the block volumes in the compartment and not using the tags, remove the filter block within the code.
    ```
    data "oci_core_volumes" "tagged_volumes" {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>       # from provider.tf
        compartment_id = var.compartment_id
        filter {
            name = "freeform_tags.<TAG NAME>"          # Replace with required tag. To use a defined tag, replace freeform_tags with defined_tags. 
            values = ["<TAG VALUE>"]
        }
    }
    ```


3. Create the volume group and assign the backup policy. If using the second solution above, replace the volume_ids field `oci_core_volumes.tagged_volumes.volumes[*].id` with a list of the OCIDs from the console - the commented out line below.

    ```
    # BACKUP POLICY PER VOLUME GROUP

    resource oci_core_volume_group block_volume_group {
        provider = oci.<PRIMARY REGION ALIAS NAME FROM PROVIDER FILE>       # from provider.tf
        availability_domain = <PRIMARY REGION AVAILABILITY DOMAIN NAME>         
        compartment_id = var.compartment_id
        display_name = "dr_volume_group"
        source_details {
            type = "volumeIds"
            volume_ids = data.oci_core_volumes.tagged_volumes.volumes[*].id
            # volume_ids = ['<BLOCK 1 OCID>', '<BLOCK 2 OCID>', '<BLOCK 3 OCID>']
        }
        backup_policy_id = oci_core_volume_backup_policy.block_backup_policy.id
    }
    ```


4. Clean-up CORE.TF - Remove any Volume resources blocks (Block Volumes, Policies, Volume Groups) defined automatically by the primary region terraform output. All we will need is the backup and on failure, we will provision the backup to a Block Volume.
