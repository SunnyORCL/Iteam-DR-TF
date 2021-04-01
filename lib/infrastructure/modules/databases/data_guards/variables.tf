
variable compartment_id {}
variable database_admin_password {}
variable database_id {}
variable shape {}
variable subnet_id  {}
variable data_guard_association_hostname {}

variable data_guard_association_nsg_ids { 
    default = [] 
}

variable ad { default = "AD-1"}

variable protection_mode {
# IMPORTANT - The only protection mode currently supported by the Database service is MAXIMUM_PERFORMANCE. 
    default = "MAXIMUM_PERFORMANCE"
}

variable transport_type {
    default = "ASYNC"
}

variable assoc_type {
    default = "NEW"
}

variable creation_type {
    default = {"NEW": "NewDbSystem", "OLD": "ExistingVmCluster"}
}

variable delete_standby_db_home_on_delete {
    default = true
}

variable display_name {
    default = ""
}

locals  {
    instance_availability_domain = {
        for ad in data.oci_identity_availability_domains.ads.availability_domains :
            regex("AD-\\d", ad.name) => ad.name
    }
}
