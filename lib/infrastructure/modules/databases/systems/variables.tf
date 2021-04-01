variable compartment_id {}
variable subnet_id {}
variable shape {}
variable ssh_public_keys {}
variable db_system_db_home_database_admin_password {}
variable hostname {}

variable data_storage_size_in_gb {
    default = "256"
}
variable license_model {
    default = ""
}
variable node_count {
    default = "1"
}

variable database_edition {
    default = "ENTERPRISE_EDITION"
}

variable disk_redundancy {
    default = "NORMAL"
}

variable ad {
    default = "AD-1"
}

variable display_name {
    default = ""
}

variable db_version { 
    default = "" 
}

variable db_system_db_home_display_name {
    default = ""
}
variable db_system_db_home_database_db_name {
    default = ""
}

locals  {
    instance_availability_domain = {
        for ad in data.oci_identity_availability_domains.ads.availability_domains :
            regex("AD-\\d", ad.name) => ad.name
    }
}