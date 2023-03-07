#!/usr/bin/env bash

# this script will initiat terraform plan,destory,validate and apply depending on subcommands.

# variables
user_input="$1"
second_arg="$2"
version="v1.2"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
EC="\e[0m"


# location of configuration
app_server_path="$(pwd)/app-server"
database_path="$(pwd)/database"
network_path="$(pwd)/network"
security_group_path="$(pwd)/security-groups"
sftp_server_path="$(pwd)/sftp-server"
var_tf="../terraform.tfvars"

# functions
install_terraform() {
        sudo apt update
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform -y
}
f_install_terraform=install_terraform

# case
case $user_input in
	"state")
		case $second_arg in
			"list")
                		
                		printf "${YELLOW}state lists${EC}\n"
				cd ${app_server_path} && terraform state list
               		 	cd ${database_path} && terraform state list
                		cd ${network_path} && terraform state list
                		cd ${security_group_path} && terraform state list
                		cd ${sftp_server_path} && terraform state list
			;;
		*)
			printf "available options [ ${YELLOW}list${EC} ]\n"
		esac
	;;
	
	"--help")
		printf "\n"
		printf ">>> \tinit\t\t\t(initialize terraform for every configuration path)\n"
		printf ">>> \tplan --help\t\t(plan the provided configuration)\n"
		printf ">>> \tplan all\t\t(plan all the configuration step by step)\n"
		printf ">>> \tstate --help\t\t(state lists of all the configuration)\n"
		printf ">>> \tapply --help\t\t(apply the provided configuration)\n"
		printf ">>> \tapply all\t\t(apply all the configuration step by step)\n"
		printf ">>> \tdestroy --help\t\t(destroy the provided configuration)\n"
		printf ">>> \tdestroy all\t\t(${RED}destroy ${EC}all the configuration on aws)\n"
		printf ">>> \tclean\t\t\t(${RED}delete all the terraform state files${EC})\n\n"
	;;

	"init")
		
		printf "${BLUE}init >>>>>\t${app_server_path}${EC}\n"
		cd ${app_server_path} && terraform init -var-file=${var_tf} &> init.log
		printf "${BLUE}init >>>>>\t${database_path}${EC}\n"
		cd ${database_path} && terraform init -var-file=${var_tf} &> init.log
		printf "${BLUE}init >>>>>\t${network_path}${EC}\n"
		cd ${network_path} && terraform init -var-file=${var_tf} &> init.log
		printf "${BLUE}init >>>>>\t${security_group_path}${EC}\n"
		cd ${security_group_path} && terraform init -var-file=${var_tf} &> init.log
		printf "${BLUE}init >>>>>\t${sftp_server_path}${EC}\n"
		cd ${sftp_server_path} && terraform init -var-file=${var_tf} &> init.log


        ;;
	"plan")
		case ${second_arg} in
			"server")
				printf "${GREEN}planing >>>>>\tapp-server${EC}\n"
				cd ${app_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}app-server configuration will fail if network and security groups configuration has not be applied before running app-server plan\n" ; exit 1
			;;
			"sftp")
				printf "${GREEN}planing >>>>>\tsftp-server${EC}\n"
				cd ${sftp_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}sftp-server configuration will fail if network and security groups configuration has not be applied before running sftp-server plan\n" ; exit 1
			;;
			"db")
				printf "${GREEN}planing >>>>>\tdatabase${EC}\n"
				cd ${database_path} && terraform plan -var-file=${var_tf} || printf "${RED}databse configuration will fail if network and security groups configuration has not be applied before running databse plan\n" ; exit 1
                        ;;
			"net")
				printf "${GREEN}planing >>>>>\tnetworks${EC}\n"
				cd ${network_path} && terraform plan -var-file=${var_tf}
                        ;;
			"sg")
				printf "${GREEN}planing >>>>>\tsecurity groups${EC}\n"
				cd ${security_group_path} && terraform plan -var-file=${var_tf} || printf "${RED}security-group configuration will fail if network  configuration has not be applied before running security-group plan\n"
                        ;;
			"all")
				set -e
				printf "\n${BLUE}planing all configuration${EC}\n"
				printf "${GREEN}planing >>>>>\tnetworks${EC}\n"
				cd ${network_path} && terraform plan -var-file=${var_tf}
				printf "${GREEN}planing >>>>>\tsecurity groups${EC}\n"
				cd ${security_group_path} && terraform plan -var-file=${var_tf} || printf "${RED}security-group configuration will fail if network  configuration has not be applied before running security-group plan\n"
				printf "${GREEN}planing >>>>>\tapp-server${EC}\n"
				cd ${app_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}server configuration will fail if network and security groups configuration has not be applied before running server plan\n"
				printf "${GREEN}planing >>>>>\tsftp-server${EC}\n"
				cd ${sftp_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}sftp-server configuration will fail if network and security groups configuration has not be applied before running sftp-server plan\n"
				printf "${GREEN}planing >>>>>\tdatabase${EC}\n"
				cd ${database_path} && terraform plan -var-file=${var_tf} || printf "${RED}database configuration will fail if network and security groups configuration has not be applied before running database plan\n"


				;;
			"--help")
				printf "${GREEN}plan server >> (app-server)${EC}\n"
				printf "${GREEN}plan sftp >> (sftp-server)${EC}\n"
				printf "${GREEN}plan db >> (database)${EC}\n"
				printf "${GREEN}plan net >> (networks)${EC}\n"
				printf "${GREEN}plan sg >> (security group)${EC}\n"
				printf "${GREEN}plan all >> (all configs)${EC}\n"
                ;;
			*)
			printf "\n${YELLOW}\tcommands\t\t\tdetails\n\n"
			printf "${GREEN}$0 plan server\tplan server configuration\n"
			printf "${GREEN}$0 plan sftp\tplan sfp-server configuration\n"
			printf "${GREEN}$0 plan db\t\tplan database configuration\n"
			printf "${GREEN}$0 plan net\t\tplan network configuration\n"
			printf "${GREEN}$0 plan sg\t\tplan security groups configuration\n"
			printf "${GREEN}$0 plan all\t\tplan all configurations\n"
		esac
        ;;

	"apply")
                case ${second_arg} in
                        "server")
                                printf "${GREEN}applying >>>>>\tapp-server${EC}\n"
                                $0 destroy server -auto-approve
				cd ${app_server_path} && terraform apply -var-file=${var_tf} ${3}
                        ;;
			"sftp")
                                printf "${GREEN}applying >>>>>\tsftp-server${EC}\n"
                                $0 destroy sftp -auto-approve &> /dev/null
				$0 apply net -auto-approve
				$0 apply sg -auto-approve 
				cd ${sftp_server_path} && terraform apply -var-file=${var_tf} ${3}
                        ;;
                        "db")
                                printf "${GREEN}applying >>>>>\tdatabase${EC}\n"
                                $0 destroy db -auto-approve
				cd ${database_path} && terraform apply -var-file=${var_tf} ${3}
                        ;;
                        "net")
                                printf "${GREEN}applying >>>>>\tnetworks${EC}\n"
                                cd ${network_path} && terraform apply -var-file=${var_tf} ${3}
                        ;;
                        "sg")
                                printf "${GREEN}applying >>>>>\tsecurity groups${EC}\n"
                                cd ${security_group_path} && terraform apply -var-file=${var_tf} ${3}
                        ;;

						"all")
								set -e
								printf "\n${BLUE}applying all configurations${EC}\n"
								printf "${GREEN}apply >>>>>\tnetworks${EC}\n"
								cd ${network_path} && terraform plan -var-file=${var_tf}
								printf "${GREEN}apply >>>>>\tsecurity groups${EC}\n"
								cd ${security_group_path} && terraform plan -var-file=${var_tf}
								printf "${GREEN}apply >>>>>\tapp-server${EC}\n"
								cd ${app_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}server configuration will fail if network and security groups configuration has not be applied before running server plan\n"
								printf "${GREEN}apply >>>>>\tdatabase${EC}\n"
								cd ${database_path} && terraform plan -var-file=${var_tf} || printf "${RED}database configuration will fail if network and security groups configuration has not be applied before running database plan\n"
								printf "${GREEN}apply >>>>>\tsftp-server${EC}\n"
								cd ${sftp_server_path} && terraform plan -var-file=${var_tf} || printf "${RED}sftp-server configuration will fail if network and security groups configuration has not be applied before running sftp-server plan\n"
                        ;;
						"--help")
							printf "${GREEN}apply server >> (app-server)${EC}\n"
							printf "${GREEN}apply sftp >> (sftp-server)${EC}\n"
							printf "${GREEN}apply db >> (database)${EC}\n"
							printf "${GREEN}apply net >> (networks)${EC}\n"
							printf "${GREEN}apply sg >> (security group)${EC}\n"
							printf "${GREEN}apply all >> (all configs)${EC}\n"
            			    ;;
                        *)
			printf "\n${YELLOW}\tcommands\t\t\tdetails\n\n"
			printf "${GREEN}$0 apply server\tplan server configuration\n"
			printf "${GREEN}$0 apply sftp\tplan sftp-server configuration\n"
			printf "${GREEN}$0 apply db\t\tplan database configuration\n"
			printf "${GREEN}$0 apply net\t\tplan network configuration\n"
			printf "${GREEN}$0 apply sg\t\tplan security groups configuration\n"
			printf "${GREEN}$0 apply all\t\tapply all configurations\n"
                esac
        ;;
	"validate")

                case ${second_arg} in
                        "server")
                                printf "${GREEN}validating configurations >>>>>\tapp-server${EC}\t"
                                cd ${app_server_path} && terraform validate
                        ;;
						"sftp")
                                printf "${GREEN}validating configurations >>>>>\tsftp-server${EC}\t"
                                cd ${sftp_server_path} && terraform validate
                        ;;
                        "db")
                                printf "${GREEN}validating configurations >>>>>\tdatabase${EC}\t"
                                cd ${database_path} && terraform validate
                        ;;
                        "net")
                                printf "${GREEN}validating configurations >>>>>\tnetworks${EC}\t"
                                cd ${network_path} && terraform validate
                        ;;
                        "sg")
                                printf "${GREEN}validating configurations >>>>>\tsecurity groups${EC}\t"
                                cd ${security_group_path} && terraform validate
                        ;;

						"all")
								set -e
								printf "\n${BLUE}validating configurations all configurations${EC}\n"
								printf "${GREEN}validating >>>>>\tnetworks${EC}\t"
								cd ${network_path} && terraform validate
								printf "${GREEN}validating >>>>>\tsecurity groups${EC}\t"
								cd ${security_group_path} && terraform validate
								printf "${GREEN}validating >>>>>\tapp-server${EC}\t"
								cd ${app_server_path} && terraform validate 
								printf "${GREEN}validating >>>>>\tdatabase${EC}\t"
								cd ${database_path} && terraform validate
								printf "${GREEN}validating >>>>>\tsftp-server${EC}\t"
								cd ${sftp_server_path} && terraform validate
                        ;;

						"--help")
							printf "${GREEN}validate server >> (app-server)${EC}\n"
							printf "${GREEN}validate sftp >> (sftp-server)${EC}\n"
							printf "${GREEN}validate db >> (database)${EC}\n"
							printf "${GREEN}validate net >> (networks)${EC}\n"
							printf "${GREEN}validate sg >> (security group)${EC}\n"
							printf "${GREEN}validate all >> (all configs)${EC}\n"
            			    ;;

                        *)
						printf "\n${YELLOW}\tcommands\t\t\tdetails\n\n"
						printf "${GREEN}$0 validate server\tplan server configuration\n"
						printf "${GREEN}$0 validate sftp\tplan sftp-server configuration\n"
						printf "${GREEN}$0 validate db\t\tplan database configuration\n"
						printf "${GREEN}$0 validate net\t\tplan network configuration\n"
						printf "${GREEN}$0 validate sg\t\tplan security groups configuration\n"
						printf "${GREEN}$0 validate all\t\tapply all configurations\n"
                esac
        ;;

	"destroy")
                case ${second_arg} in
                        "server")
                                printf "${GREEN}running destroy command >>>>>\tapp-server${EC}\t"
                                cd ${app_server_path} && terraform destroy -var-file=${var_tf} ${3}
                        ;;
						"sftp")
                                printf "${GREEN}running destroy command >>>>>\tsftp-server${EC}\t"
                                cd ${sftp_server_path} && terraform destroy -var-file=${var_tf} ${3}
                        ;;
                        "db")
                                printf "${GREEN}running destroy command >>>>>\tdatabase${EC}\t"
                                cd ${database_path} && terraform destroy -var-file=${var_tf} ${3}
                        ;;
                        "net")
                                printf "${GREEN}running destroy command >>>>>\tnetworks${EC}\t"
                                cd ${network_path} && terraform destroy -var-file=${var_tf} ${3}
                        ;;
                        "sg")
                                printf "${GREEN}running destroy command >>>>>\tsecurity groups${EC}\t"
                                cd ${security_group_path} && terraform destroy -var-file=${var_tf} ${3}
                        ;;

						"all")
								read -p "Do you want to destroy all the resources? [y/n] " response
								if [[ $response = 'y' ]]
								then
									set -e
									printf "\n${RED}running destroy command for all configurations${EC}\n"

									printf "${GREEN}running destroy command >>>>>\tsftp-server${EC}\t"
									cd ${sftp_server_path} && terraform destroy -var-file=${var_tf} -auto-approve

                                    					printf "${GREEN}running destroy command >>>>>\tdatabase${EC}\t"
                                    					cd ${database_path} && terraform destroy -var-file=${var_tf} -auto-approve


                                    					printf "${GREEN}running destroy command >>>>>\tapp-server${EC}\t"
                                    					cd ${app_server_path} && terraform destroy -var-file=${var_tf} -auto-approve

									printf "${GREEN}running destroy command >>>>>\tsecurity groups${EC}\t"
                                                                        cd ${security_group_path} && terraform destroy -var-file=${var_tf} -auto-approve

                                                                        printf "${GREEN}running destroy command >>>>>\tnetworks${EC}\t"
                                                                        cd ${network_path} && terraform destroy -var-file=${var_tf} -auto-approve



                                    exit 0
								else
									printf "\n${YELLOW}aborting destroy command for configurations${EC}\n"
								fi

								
                        ;;

						"--help")
							printf "${GREEN}destroy server >> (app-server)${EC}\n"
							printf "${GREEN}destroy sftp >> (sftp-server)${EC}\n"
							printf "${GREEN}destroy db >> (database)${EC}\n"
							printf "${GREEN}destroy net >> (networks)${EC}\n"
							printf "${GREEN}destroy sg >> (security group)${EC}\n"
							printf "${GREEN}destroy all >> (all configs)${EC}\n"
            			    ;;
                        *)
						printf "\n${YELLOW}\tcommands\t\t\t\tdetails\n\n"
						printf "${GREEN}$0 destroy server\t\tdestroy server configuration\n"
						printf "${GREEN}$0 destroy sftp\t\tdestroy sfp-server configuration\n"
						printf "${GREEN}$0 destroy db\t\t\tdestroy database configuration\n"
						printf "${GREEN}$0 destroy net\t\tdestroy network configuration\n"
						printf "${GREEN}$0 destroy sg\t\t\tdestroy security groups configuration\n"
						printf "${GREEN}$0 destroy all\t\tdestroy all configurations\n"
                esac
				;;
	"status")
		# initial status
		printf "\t${YELLOW}$(echo $0 | cut -d "/" -f 2) version_${version}\t${EC}\n\n"
		terraform version &> /dev/null && printf "terraform version: ${GREEN}$(terraform version | head -1| cut -d " " -f2)${EC}\n"
		terraform version &> /dev/null || printf "terraform version: ${EC}\t${RED}Not installed${EC}\t<try $0 install terraform>\n"
		printf "supported provider: ${GREEN}aws${EC}\n"
		printf "terraform varfile: ${GREEN}terraform.tfvars${EC}\n"
	;;
	"install")
		case "$2" in
			"terraform")
				if $(terraform version &> /dev/null) ;
				then
					echo "terraform already installed"
				else
					echo "installing terraform..."
					${f_install_terraform} && echo -e "${GREEN}terraform installed${EC}\n" && $0 status
				fi
				;;
			*)
				printf "available option [terraform]\n"
		esac
	;;
        "clean")
                # deletes all the tf state files and .terraform directory which requires new initialization at the start

		if [[ $(id -u) == 0 ]]
		then
			read -p "Delete all the terraform state files? [y/n] " clean_response
			if [[ ${clean_response} == 'y' ]]
			then
				set -e
				printf "${RED}removing state files >>> networks${EC}\n"
				cd ${network_path} && rm -rf .terraform terraform.tfstate.backup terraform.tfstate .terraform.lock.hcl init.log
				printf "${RED}removing state files >>> security groups${EC}\n"
                		cd ${security_group_path} && rm -rf .terraform terraform.tfstate.backup terraform.tfstate .terraform.lock.hcl init.log
				printf "${RED}removing state files >>> database${EC}\n"
                		cd ${database_path} && rm -rf .terraform terraform.tfstate.backup terraform.tfstate .terraform.lock.hcl init.log
				printf "${RED}removing state files >>> app-server${EC}\n"
                		cd ${app_server_path} && rm -rf .terraform terraform.tfstate.backup terraform.tfstate .terraform.lock.hcl init.log
				printf "${RED}removing state files >>> sfp-server${EC}\n"
				cd ${sftp_server_path} && rm -rf .terraform terraform.tfstate.backup terraform.tfstate .terraform.lock.hcl init.log
				printf "${GREEN}cleared all the statefiles${EC}\n"
			fi
		else
			printf "${RED}this action requires root privilege\n" && exit 1
		fi
        ;;
	*)
		printf "${YELLOW}invalid command, try --help for the help\n"
esac


