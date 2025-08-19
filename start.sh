#!/bin/bash
# Start Ghost Nation Script v.08
# Colorize:
# Cores para mensagens
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[1;33m"
CYAN="\e[0;36m"
NC="\e[0m" # No Color
#
echo -e  "${YELLOW}Updating your Ubuntu Server${NC}"
sudo apt update && sudo apt upgrade -y
#
# Disabling unnecessary services
sudo systemctl stop cloud-init
sudo systemctl disable cloud-init
sudo systemctl disable --now unattended-upgrades
#
sudo apt install git net-tools vim htop lm-sensors nmap dos2unix iptables-persistent -y
#
echo -e  "${GREEN}"
echo -e  "##################################"
echo -e  "## Welcome to Ghost Node Nation ##"
echo -e  "##################################${NC}"

echo -e  ""
echo -e  "${CYAN}Download Github Project${NC}"
sudo git clone https://github.com/greycitizen/ghostnodes.git /root/nodenation
sudo find /root/nodenation/ -type f -name "*.sh" -print0 | xargs -0 sudo dos2unix

echo -e  "${CYAN}Changing permition to scripts:${NC} "
echo -e  ""
sudo find /root/nodenation/ -name "*.sh" -type f -print0 | xargs -0 sudo chmod +x

# Execute the Menu:
echo -e  "${GREEN}###########################################"
echo -e  "############ Make Your Ghost ##############"
echo -e  "###########################################"
echo -e  "${NC}"

echo -e  "##################################"
echo -e  " 1 - Install Halfin Node"
echo -e  " 2 - Install Satoshi Node"
echo -e  " 3 - Install Nick Node"
echo -e  " 4 - Install Craig Node"
echo -e  " 5 or another option - Out"
echo -e  "##################################"
echo -e  ""
read -p "Choose your pill: " escolha </dev/tty
echo -e  ""

pasta1="/root/nodenation/"

case $escolha in

    1)
        echo -e  "${GREEN}"
	echo -e  "#################################"
	echo -e  "Running Halfin Node..."
	echo -e  ""
	echo -e  "#################################"
    echo -e  "#### What is your equipment? ####"
	echo -e  "#################################"
	echo -e  "${NC}

	Ubuntu Server installed on:

	[1] RaspBerry Pi + Dongle Wifi
	[2] Raspberry Pi no Dongle
	[3] Banana Pi Zero 
	[4] Orange Pi Zero 3 + Dongle
	#################################
	"
	pasta2="/root/halfin/"
        read -p "${RED}Choose your config:${NC} " TIPO
        if [[ "$TIPO" == "1" ]]; then
	newfolder="halfin"
        
        $pasta2./alias.sh </dev/tty
        $pasta2./script_rasp.sh </dev/tty
        fi
        if [[ "$TIPO" == "3" ]]; then
        curl -sS https://raw.githubusercontent.com/greycitizen/ghostnodes/refs/heads/main/halfin/script_openwrt.sh | bash
        fi
	
        if [[ "$TIPO" == "4" ]]; then
	newfolder="halfin"
  
  	mv $pasta1'halfin' /root/ </dev/tty
        $pasta2./alias.sh </dev/tty
        $pasta2./script_orange3.sh </dev/tty
        fi
	
        if [[ "$TIPO" == "2" ]]; then
        echo -e  "Script on test fase v0.4"
        exit 0
        fi
        ;;
    2)

	echo -e  "${GREEN}"
	echo -e  "##########################################"
	echo -e  "######## Instalando Satoshi Node #########"
	echo -e  "##########################################"
	echo -e  "${NC}"

	satoshi="/home/pleb/./installcore.sh"
				sudo mv /root/nodenation/satoshi/scripts/*.sh /home/pleb/ </dev/tty

        if [ -d "$satoshi" ]; then
            echo -e  "${CYAN}Instalar o Satoshi Node...${NC}"

   			# Instalation, Configuration and Tools for "Satoshi Node" Ago/2025 0.8.0v

				sudo mv /root/nodenation/satoshi/scripts/bitcoin.conf /home/pleb/ </dev/tty
				sudo chown pleb:pleb /home/pleb/* </dev/tty
				sudo rm -R /root/nodenation </dev/tty
				sudo apt install cron net-tools vim nano htop lm-sensors nmap tree openssh-server iptraf-ng iw -y
	            
			 	echo "###########################################"
			 	echo "Execute this comand with no root privileges:"
			 	echo "/home/pleb/./installcore.sh"	 
			 	echo "###########################################"
	 		exit 0
	
		else
            echo -e  "Erro: folder $satoshi not found!"
            exit 1
        fi
        ;;
    3)
        if [ -f "/nick/script_n.sh" ]; then
            echo -e  "Nick Node Installation..."
            /bin/bash /nick/script_n.sh </dev/tty
        else
            echo -e  "${YELLOW}######################################"
	    echo -e  "#### News coming soon for Nick... ####"
            echo -e  "######################################${NC}"
            exit 1
        fi
        ;;
    4)
        if [ -f "/craig/script_c.sh" ]; then
            echo -e  "Fooling Craig Node..."
            /bin/bash /craig/script_c.sh </dev/tty
        else
            echo -e  "${YELLOW}#######################################"
	        echo -e  "##### Erro: Fooling Craig Node... #####"
            echo -e  "#######################################${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e  "${RED}Nothing to do!${NC}"
	echo -e  ""
 	echo -e  "${CYAN}##### If you want to go back to the installation, type: sudo /root/$newfolder/menu.sh ######${NC}"
 	echo -e  ""
        exit 0
        ;;
esac
