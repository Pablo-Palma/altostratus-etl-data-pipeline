resource "null_resource" "transformation" {
  provisioner "local-exec" {
    command = "echo 'Running transformation logic...'"
  }
}

