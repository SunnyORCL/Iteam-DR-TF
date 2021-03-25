/* This script creates backup of the boot volume from the primary region's app server, copies it to the standby region, 
and spins up an instance from the boot volume. Once app server is intialized, runs additional scripts from the compute to finish application set-up. */


# INITIALIZE APP SERVER

# create instance from boot volume
resource oci_core_instance app_instance {
  metadata = {
    ssh_authorized_keys = file(var.compute_ssh_pub_key)
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = data.oci_identity_availability_domain.AD-1.name
  compartment_id      = var.compartment_ocid
  create_vnic_details {
    assign_public_ip = "true"
    display_name = var.compute_vnic_display_name
    hostname_label = var.compute_hostname
    subnet_id  = oci_core_subnet.appSubnet1.id 
  }
  display_name = var.compute_display_name
  shape = var.compute_shape
  source_details {
    source_id = oci_core_boot_volume.restored_boot_volume.id
    source_type = "bootVolume"
  }
}

# backup boot volume within primary region
resource "oci_core_boot_volume_backup" "initial_boot_volume_backup" {
    provider = oci.primary_region
    display_name = var.boot_volume_backup_display_name
    boot_volume_id = var.primary_boot_volume_ocid
}

# copy boot volume backup to standby region
resource "oci_core_boot_volume_backup" "boot_volume_backup_cross_regional" {
    display_name = var.boot_volume_backup_display_name
    source_details {
        region = "us-sanjose-1"
        boot_volume_backup_id = oci_core_boot_volume_backup.initial_boot_volume_backup.id
    }
}

# restore backup to boot volume
resource "oci_core_boot_volume" "restored_boot_volume" {
    availability_domain = data.oci_identity_availability_domain.AD-1.name
    compartment_id = var.compartment_ocid
    source_details {
        id = oci_core_boot_volume_backup.boot_volume_backup_cross_regional.id
        type = "bootVolumeBackup"
    }
    display_name = var.restored_boot_volume_display_name
}


# SET-UP APPLICATION

resource "null_resource" SETUP_COMPUTE_BY_SSH {
    depends_on = [oci_core_instance.app_instance]
    connection {
    type     = "ssh"
    user     = "opc"
    private_key = file(var.compute_ssh_private_key)
    host     = oci_core_instance.app_instance.public_ip
  }
    provisioner "remote-exec" {
      inline = [
        "sudo systemctl start docker",
        "sudo usermod -aG docker opc"
      ]
    }
}
resource "null_resource" SETUP_APP_BY_SSH {
    depends_on = [oci_core_instance.app_instance, null_resource.SETUP_COMPUTE_BY_SSH]
    connection {
    type     = "ssh"
    user     = "opc"
    private_key = file(var.compute_ssh_private_key)
    host     = oci_core_instance.app_instance.public_ip
  }
    provisioner "remote-exec" {
      inline = [
        "cd oracle.r2r.simple-app",
        "docker build -t simpleapp:latest .",
        "docker run -d -p 80:3000 simpleapp"
      ]
    }
}
