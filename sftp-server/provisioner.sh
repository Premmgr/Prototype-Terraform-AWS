#!/usr/bin/bash

# variables
var_user="ftpuser"
var_password="stage"
var_shell="/bin/bash"


# add ftpuser on the system
sudo mkdir /home/${var_user}
sudo chown ${var_user}:${var_user} /home/${var_user}
sudo useradd --home /home/${var_user} --shell ${var_shell} -p $(openssl passwd -6 ${var_password}) ${var_user}


# install vsftpd
sudo apt-get update && sudo apt-get install -y vsftpd
