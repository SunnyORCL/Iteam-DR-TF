# OCI (existing)
variable compartment_ocid { }
variable standby_region { default = "eu-frankfurt-1" }
variable primary_region { default = "us-sanjose-1" }

# AUTHENTICATION (existing)
variable api_fingerprint { }
variable api_private_key_path { }
variable tenancy_id {  }
variable user_id { }

# --------------------------------------------------------------------

# STANDBY REGION NETWORKING
variable vcn_display_name { default = "StandbyVCN" }
variable vcn_cidr { default = "10.1.0.0/16" }
variable vcn_dns { default = "standbydr1" }

variable subnet_cidr { default = "10.1.0.0/24" }
variable subnet_display_name { default = "AppSubnet" }
variable subnet_dns { default = "appsubnet" }

variable internet_gateway_display_name { default = "StandbyInternetGW" }
variable standby_drg_display_name { default = "StandbyRegionDRG"}
variable standby_rpc_display_name { default = "StandbyRegionRPC"}

# DB Specific Networking
variable db_security_list_display_name { default = "DB Security List" }

# LB Specific Networking
variable lb_subnet_cidr { default = "10.1.1.0/24" }
variable lb_subnet_display_name { default = "LBSubnet" }
variable lb_security_list_display_name { default = "LB Security List" }
variable lb_subnet_dns { default = "lbsubnet" }

# STANDBY REGION DB
variable standby_db_display_name { default = "StandbyDB1"}
variable standby_db_hostname { default = "standbydb1"}
variable delete_standby_db_home_on_delete { default = "true"}

# STANDBY REGION LOAD BALANCER
variable load_balancer_display_name { default = "dr-lb-tf" }

# STANDBY REGION COMPUTE
variable compute_shape { default = "VM.Standard2.2" }
variable compute_ssh_pub_key { }
variable compute_ssh_private_key {  }
variable compute_display_name { default = "terraform1" }
variable compute_hostname { default = "terraform1" }
variable compute_vnic_display_name { default = "terraform1" }

variable compute_image_id {  }

variable boot_volume_backup_display_name { default ="initialBackup" }
variable restored_boot_volume_display_name { default = "appBootVol" }


# STANDBY REGION BLOCK VOLUMES
variable block_backup_policy_display_name { default = "block_backup_policy" }
variable block_tag { default = "freeform_tags.environment" }    # To use a defined tag, replace freeform_tags with defined_tags.
variable block_tag_value { default = "dev1" }
variable block_volume_group_display_name { default = "block_volume_group" }

# --------------------------------------------------------------------

# PRIMARY REGION VCN (existing)
variable primary_vcn_cidr { default = "10.0.0.0/16" }
variable primary_vcn_ocid { }
variable primary_drg_ocid { }

variable bronze_backup_policy { default = "ocid1.volumebackuppolicy.oc1..aaaaaaaadrzfwjb5tflixtmy5axp2kx65uqakgnupfogabzjhtn5x5dfra6q"}
variable primary_boot_volume_ocid {  }

# PRIMARY REGION DB (existing)
variable primary_db_ocid { }
variable primary_db_admin_password { }
variable primary_db_vm_shape { }

# PRIMARY REGION RPC
variable primary_drg_display_name { default = "PrimaryRegionDRG"}
variable primary_rpc_display_name { default = "PrimaryRegionRPC"}