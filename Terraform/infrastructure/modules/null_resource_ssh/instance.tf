resource "null_resource" SETUP_COMPUTE_BY_SSH {
    depends_on = [var.dependent_on]

    connection {
    type     = "ssh"
    user     = var.user
    private_key = var.private_key
    host     = var.host
  }
    provisioner "remote-exec" {
      inline = var.inline_commands
    }
}