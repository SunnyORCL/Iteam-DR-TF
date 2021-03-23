# OCI (existing)
variable compartment_ocid { }
variable standby_region { }
variable primary_region {  }

# AUTHENTICATION (existing)
variable api_fingerprint { }
variable api_private_key_path { }
variable tenancy_id { default =  "ocid1.tenancy.oc1..aaaaaaaaplkmid2untpzjcxrmbv4nowe74yb4lr6idtckwo4wyf7jh23be4q" }
variable user_id { }

# --------------------------------------------------------------------

# STANDBY REGION NETWORKING
variable vcn_display_name { default = "StandbyVCN" }
variable vcn_cidr { default = "10.1.0.0/16" }
variable vcn_dns { default = "standbydr1" }

variable subnet_cidr { default = "10.1.0.0/24" }
variable subnet_display_name { default = "SubnetA" }
variable subnet_dns { default = "standbysubnet1" }

variable internet_gateway_display_name { default = "StandbyInternetGW" }
variable standby_drg_display_name { default = "StandbyRegionDRG"}
variable standby_rpc_display_name { default = "StandbyRegionRPC"}

# DB Specific Networking
variable db_security_list_display_name { default = "DB Security List" }

# LB Specific Networking
variable lb_subnet_cidr { default = "10.1.1.0/24" }
variable lb_subnet_display_name { default = "lbSubnet1" }
variable lb_security_list_display_name { default = "LB Security List" }
variable lb_subnet_dns { default = "lbSubnet1" }

# STANDBY REGION DB
variable standby_db_display_name { default = "StandbyDB1"}
variable standby_db_hostname { default = "standbydb1"}
variable delete_standby_db_home_on_delete { default = "true"}

# STANDBY REGION LOAD BALANCER
variable load_balancer_display_name { default = "dr-lb-tf" }

# STANDBY REGION COMPUTE
variable compute_image_id { default = "ocid1.image.oc1.us-sanjose-1.aaaaaaaadey32wkjps5dnyheo3nesfetaae4pj5xq5gvmsksxblpylsbhuia" }
variable compute_shape { default = "VM.Standard2.2" }

# STANDBY REGION BLOCK VOLUMES
variable block_backup_policy_display_name { default = "block_backup_policy" }
variable block_tag { default = "freeform_tags.environment" }    # To use a defined tag, replace freeform_tags with defined_tags.
variable block_tag_value { default = "dev1" }
variable block_volume_group_display_name { default = "block_volume_group" }

# --------------------------------------------------------------------

# PRIMARY REGION VCN (existing)
variable primary_vcn_cidr { default = "10.0.0.0/16" }
variable primary_vcn_ocid { default = "ocid1.vcn.oc1.us-sanjose-1.amaaaaaantxkdlyaze57vxthzjolubkdcu2tslaukdtp3z5emqmsk57dsi7a"}
variable primary_drg_ocid { default = "ocid1.drg.oc1.us-sanjose-1.aaaaaaaazehirlxbl7b35n5rcunsn5f2qitt7pu4uqhhpsx4nss4cwawp47q"}


# PRIMARY REGION DB (existing)
variable primary_db_ocid { default = "ocid1.database.oc1.us-sanjose-1.abzwuljrav2vhaojroymkhbgxfe6nywlmw2dg3wiwa7i2rnzkx55ucswijcq"}
variable primary_db_admin_password { default = "WelcomeDB123##"}
variable primary_db_vm_shape { default = "VM.Standard2.4"}

# PRIMARY REGION RPC
variable primary_drg_display_name { default = "PrimaryRegionDRG"}
variable primary_rpc_display_name { default = "PrimaryRegionRPC"}