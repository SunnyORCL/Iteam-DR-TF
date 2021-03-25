resource "oci_database_data_guard_association" "data_guard_association" {
  #Required
  creation_type                    = var.creation_type[var.assoc_type]
  database_admin_password          = var.database_admin_password
  database_id                      = var.database_id
  protection_mode                  = var.protection_mode
  transport_type                   = var.transport_type
  delete_standby_db_home_on_delete = var.delete_standby_db_home_on_delete

  #required for NewDbSystem creation_type
  display_name        = var.display_name
  shape               = var.shape
  subnet_id           = var.subnet_id
  availability_domain = local.instance_availability_domain[var.ad]
  nsg_ids             = var.data_guard_association_nsg_ids
  hostname            = var.data_guard_association_hostname
}