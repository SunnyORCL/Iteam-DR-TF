# /* This script creates a backup policy, filters block volumes by tag, and then provides two methods of applying the policy to all tagged volumes: 
# (1) creating a volume group out of the tagged volumes and applying the policy to the group or (2) assigning the policy to each individual volume.
# */


# Create Volume Group

data "oci_core_volumes" "tagged_volumes" {
    provider = oci.primary_region
    compartment_id = var.compartment_ocid
    filter {
      name = var.block_tag         
      values = [var.block_tag_value]
    }
}

data oci_identity_availability_domain primary-AD-1 {
  provider = oci.primary_region
  compartment_id = var.compartment_ocid
  ad_number      = "1"
}

resource oci_core_volume_group block_volume_group {
  provider = oci.primary_region
  availability_domain = data.oci_identity_availability_domain.primary-AD-1.name          
  compartment_id = var.compartment_ocid
  display_name = var.block_volume_group_display_name
  source_details {
    type = "volumeIds"
    volume_ids = concat(data.oci_core_volumes.tagged_volumes.volumes[*].id, [var.primary_boot_volume_ocid])
  }
  backup_policy_id = var.bronze_backup_policy
}




# # CUSTOM POLICY:

# # resource oci_core_volume_backup_policy block_backup_policy {
# #   provider = oci.primary_region
# #   compartment_id = var.compartment_ocid
# #   destination_region = var.standby_region
# #   display_name = var.block_backup_policy_display_name
# #   schedules {
# #     backup_type       = "FULL"
# #     day_of_month      = "1"
# #     day_of_week       = "MONDAY"
# #     hour_of_day       = "0"
# #     month             = "JANUARY"
# #     offset_seconds    = "0"
# #     offset_type       = "STRUCTURED"
# #     period            = "ONE_MONTH"
# #     retention_seconds = "2678400"
# #     time_zone         = "UTC"
# #   }
# # }
