data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["stage"]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "selected" {
  filter {
    name   = "group-name"
    values = ["sec-grp"]
  }
}

resource "aws_instance" "app-server" {
  ami           = "${var.AWS_AMI}"
  instance_type = "${var.AWS_INSTANCE_TYPE}"
  key_name      = "${var.AWS_SSH_KEY}"
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  subnet_id              = data.aws_subnet.selected.id
  associate_public_ip_address = true
	lifecycle {
    	create_before_destroy = true
	}
  tags = {
    Name = "app-server"
  }
  connection {

        type    = "ssh"
        user    = "ubuntu"
        private_key = file("${var.PROVISION_SSH_KEY}")
        host    = self.public_ip
    }

    provisioner "remote-exec" {
        inline = [
            "https://github.com/Premmgr/demo-app-server.git",
	          "git clone https://github.com/Premmgr/rtbackup_linux.git",
            "cd demo-app-server && bash -xvc ./app_init.sh &> logs/app_logs",
        ]
    }
}
resource "aws_eip" "app-server" {
  vpc = true
}

resource "aws_eip_association" "app-server" {
  instance_id = aws_instance.app-server.id
  allocation_id = aws_eip.app-server.id
}