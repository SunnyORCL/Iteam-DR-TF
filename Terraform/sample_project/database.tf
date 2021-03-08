/* Sample script for data guard association. This script assumes that networking (specifically, remote peering connection
    and security lists) have been set up. 
*/

resource oci_database_data_guard_association test_data_guard_association {
  provider = oci.sanjose
  creation_type = "NewDbSystem" 
  database_id = "ocid1.database.oc1.us-sanjose-1.abzwuljrav2vhaojroymkhbgxfe6nywlmw2dg3wiwa7i2rnzkx55ucswijcq"
  database_admin_password = "DBPassword123##"
  delete_standby_db_home_on_delete = "true"
  protection_mode = "MAXIMUM_PERFORMANCE"
  transport_type = "ASYNC"

  #Required for NewDbSystem
  display_name = "StandbyDB1"
  shape  = "VM.Standard2.4"
  availability_domain = data.oci_identity_availability_domain.rLid-EU-FRANKFURT-1-AD-1.name
  subnet_id = oci_core_subnet.standbysubnet1.id
  hostname = "standbydb1"
}