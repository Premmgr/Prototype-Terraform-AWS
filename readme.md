#NOTE  
```rework required for bash script```  
```this repository will be delted and impleted on python-infrastructure```  

--------------------------------------
repository contains all the required tool to create (vpc,vpc-subnet,internet gw,security groups,instance,elastic ip etc)
code owner: prem gharti

usage:

launch instance
> init > plan > apply 

destroy instance 
> ./mtool-tf.sh destroy <option> or all
mtool-tf.sh description:

mtool-tf.sh tool can ( init,plan,apply,destroy,clean tfstate )
use ./mtool-tf.sh --help for further help.
full guided video link: <under process>

-------------------------------------------------------------------------
note: 
terraform.tfvars includes required important variables which are secret.
so modify and replace with your correct information.
-------------------------------------------------------------------------
each terraform configuration process.

network:
create vpc called stage, create vpc-subnet called stage, create internet gateway.

security groups:
create security group called sec-grp and associate with stage-vpc.

database:
automatically launch e2c instance called database using terraform.tfvars value, (instance type,ssh-key)
uses stage-vpc created by network terraform configuration.
perform remote exec and clone git repository provided in db-instance.tf
execute shell script for provisioning perpose.

app-server: 
automatically launch e2c instance called app-server using terraform.tfvars value, (instance type,ssh-key)
uses stage-vpc created by network terraform configuration.
perform remote exec and clone git repository provided in app-server.tf

sftp-server:
automatically launch e2c instance called sftp-server using terraform.tfvars value, (instance type,ssh-key)
uses stage-vpc created by network terraform configuration.
perform remote exec provision shell script to execute required command to install sftp service on the sftp-server.

any bugs or unfixed codes are going to be update ASAP.
-------------------------------------------------------------------------


