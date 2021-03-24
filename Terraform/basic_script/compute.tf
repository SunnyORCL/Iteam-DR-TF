
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
    subnet_id  = oci_core_subnet.standbySubnet1.id 
  }
  display_name = var.compute_display_name
  shape = var.compute_shape
  # source_details {
  #   source_id = oci_core_boot_volume.restored_boot_volume.id
  #   source_type = "bootVolume"
  # }
  source_details {
    source_id = var.compute_image_id
    source_type = "image"
  }
}

# resource "oci_core_boot_volume_backup" "initial_boot_volume_backup" {
#     display_name = var.boot_volume_backup_display_name
#     source_details {
#         region = "us-sanjose-1"
#         boot_volume_backup_id = var.primary_boot_volume_ocid
#     }
# }


# resource "oci_core_boot_volume" "restored_boot_volume" {
#     #Required
#     availability_domain = data.oci_identity_availability_domain.AD-1.name
#     compartment_id = var.compartment_ocid
#     source_details {
#         #Required
#         id = oci_core_boot_volume_backup.initial_boot_volume_backup.id
#         type = "bootVolumeBackup"
#     }
#     display_name = var.restored_boot_volume_display_name
#     # is_auto_tune_enabled = var.boot_volume_is_auto_tune_enabled
#     # kms_key_id = oci_kms_key.test_key.id
#     # size_in_gbs = var.boot_volume_size_in_gbs
#     # vpus_per_gb = var.boot_volume_vpus_per_gb
# }

# Set-Up Application

# resource "null_resource" SETUP_COMPUTE_BY_SSH {
#     depends_on = [oci_core_instance.app_instance]
#     connection {
#     type     = "ssh"
#     user     = "opc"
#     private_key = file(var.compute_ssh_private_key)
#     host     = oci_core_instance.app_instance.public_ip
#   }
#     provisioner "remote-exec" {
#       inline = [
#         "sudo systemctl start docker",
#         "sudo usermod -aG docker opc"
#       ]
#     }
# }
# resource "null_resource" SETUP_APP_BY_SSH {
#     depends_on = [oci_core_instance.app_instance, null_resource.SETUP_COMPUTE_BY_SSH]
#     connection {
#     type     = "ssh"
#     user     = "opc"
#     private_key = file(var.compute_ssh_private_key)
#     host     = oci_core_instance.app_instance.public_ip
#   }
#     provisioner "remote-exec" {
#       inline = [
#         "cd oracle.r2r.simple-app",
#         "docker build -t simpleapp:latest .",
#         "docker run -d -p 80:3000 simpleapp"
#       ]
#     }
# }


# If created by image instead of boot volume

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
        "sudo yum install docker-engine -y",
        "sudo yum install git-all -y",
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
        "rm -rf oracle.r2r.simple-app",
        "git clone https://github.com/naberin/oracle.r2r.simple-app.git && cd oracle.r2r.simple-app",
        "docker build -t simpleapp:latest .",
        "docker run -d -p 80:3000 simpleapp"
      ]
    }
}

