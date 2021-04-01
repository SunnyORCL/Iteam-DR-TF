resource "oci_database_db_system" "db_system" {
  # required
  availability_domain     = local.instance_availability_domain[var.ad]
  compartment_id          = var.compartment_id
  hostname                = var.hostname
  shape                   = var.shape
  ssh_public_keys         = var.ssh_public_key
  subnet_id               = var.subnet_id

  # optional
  database_edition        = var.database_edition
  disk_redundancy         = var.disk_redundancy
  domain                  = data.oci_core_subnet.subnet.subnet_domain_name
  data_storage_size_in_gb = var.data_storage_size_in_gb
  license_model           = var.license_model
  node_count              = var.node_count
  display_name            = var.display_name

  db_home {
    database {
      # required
      admin_password = var.db_system_db_home_database_admin_password
      # optional
      db_name        = var.db_system_db_home_database_db_name
    }
    # optional 
    db_version   = var.db_version
    display_name = var.db_system_db_home_display_name
  }
}