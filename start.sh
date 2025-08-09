#!/bin/bash
# Start Ghost Nation Script v.07
# Colorize:
# Cores para mensagens
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color
#
echo "${YELLOW}Updating your Ubuntu Server${NC}"
sudo apt update && sudo apt upgrade -y
#
# Disabling unnecessary services
sudo systemctl stop cloud-init
sudo systemctl disable cloud-init
sudo systemctl disable --now unattended-upgrades
#
sudo apt install git net-tools vim htop lm-sensors nmap dos2unix iptables-persistent -y
#
echo "${GREEN}"
echo "##################################"
echo "## Welcome to Ghost Node Nation ##"
echo "##################################${NC}"

echo ""
echo "${CYAN}Download Github Project${NC}"
sudo git clone https://github.com/greycitizen/ghostnodes.git /root/nodenation
sudo find /root/nodenation/ -type f -name "*.sh" -print0 | xargs -0 dos2unix

echo "${CYAN}Changing permition to scripts:${NC} "
echo ""
sudo find /root/nodenation/ -name "*.sh" -type f -print0 | xargs -0 chmod +x

# Execute the Menu:
echo "${GREEN}###########################################"
echo "############ Make Your Ghost ##############"
echo "###########################################"
echo "${NC}"

echo "##################################"
echo " 1 - Install Halfin Node"
echo " 2 - Install Satoshi Node"
echo " 3 - Install Nick Node"
echo " 4 - Install Craig Node"
echo " 5 or another option - Out"
echo "##################################"
echo ""
read -p "${RED}Choose your pill:${NC} " escolha </dev/tty
echo ""

pasta1="/root/nodenation/"

case $escolha in

    1)
        echo "${GREEN}"
	echo "#################################"
	echo "Running Halfin Node..."
	echo ""
	echo "#################################"
    echo "#### What is your equipment? ####"
	echo "#################################"
	echo "${NC}"

	Ubuntu Server installed on:

	[1] RaspBerry Pi + Dongle Wifi
	[2] Raspberry Pi no Dongle
	[3] Banana Pi Zero 
	[4] Orange Pi Zero 3 + Dongle
	#################################
	"
	pasta2="/root/halfin/"
        read -p "${RED}Choose your config:${NC} " TIPO </dev/tty
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
  
  	mv $pasta1'halfin' /root/
        $pasta2./alias.sh </dev/tty
        $pasta2./script_orange3.sh </dev/tty
        fi
	
        if [[ "$TIPO" == "2" ]]; then
        echo "Script on test fase v0.4"
        exit 0
        fi
        ;;
    2)

	echo "${GREEN}"
	echo "##########################################"
	echo "######## Instalando Satoshi Node #########"
	echo "##########################################"
	echo "${NC}"

	satoshi=$pasta1"satoshi/script_s.sh"

        if [ -f "$satoshi" ]; then
            echo "${CYAN}Instalar o Satoshi Node...${NC}"
            /bin/bash $satoshi
        else
            echo "Erro: $satoshi not found!"
            exit 1
        fi
        ;;
    3)
        if [ -f "/nick/script_n.sh" ]; then
            echo "Nick Node Installation..."
            /bin/bash /nick/script_n.sh </dev/tty
        else
            echo "${YELLOW}######################################"
	    echo "#### News coming soon for Nick... ####"
            echo "######################################${NC}"
            exit 1
        fi
        ;;
    4)
        if [ -f "/craig/script_c.sh" ]; then
            echo "Fooling Craig Node..."
            /bin/bash /craig/script_c.sh </dev/tty
        else
            echo "${YELLOW}#######################################"
	        echo "##### Erro: Fooling Craig Node... #####"
            echo "#######################################${NC}"
            exit 1
        fi
        ;;
    *)
        echo "${RED}Nothing to do!${NC}"
	echo ""
 	echo "${CYAN}##### If you want to go back to the installation, type: sudo /root/$newfolder/menu.sh ######${NC}"
 	echo ""
        exit 0
        ;;
esac
