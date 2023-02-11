data "aws_instance" "sftpserver" {
  filter {
    name   = "tag:Name"
    values = ["ftp-server"]
  }
}

output "instance_id" {
  value = "${data.aws_instance.sftpserver.id}"
}

output "public_ip" {
  value = "${data.aws_instance.sftpserver.public_ip}"
}

connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("${var.PROVISION_SSH_KEY}")
    host = data.aws_instance.sftpserver.public_ip
}
