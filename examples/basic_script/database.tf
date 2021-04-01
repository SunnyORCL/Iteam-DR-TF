/* Create dataguard association for primary region DB to standby region. */

resource oci_database_data_guard_association vm_db_data_guard_association {
  provider = oci.primary_region
  creation_type = "NewDbSystem" 
  database_id = var.primary_db_ocid
  database_admin_password = var.primary_db_admin_password
  delete_standby_db_home_on_delete = var.delete_standby_db_home_on_delete
  protection_mode = "MAXIMUM_PERFORMANCE"
  transport_type = "ASYNC"

  display_name = var.standby_db_display_name
  shape  = var.primary_db_vm_shape
  availability_domain = data.oci_identity_availability_domain.AD-1.name
  subnet_id = oci_core_subnet.dbSubnet1.id
  hostname = var.standby_db_hostname

  depends_on = [
    oci_core_remote_peering_connection.standby_rpc,   # need to create peering VCNs
  ]
}