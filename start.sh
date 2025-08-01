#!/bin/bash
# Start Ghost Nation Script v.06
#
echo "Updating your Ubuntu Server"
sudo apt update && sudo apt upgrade -y
#
# Disabling unnecessary services
sudo systemctl stop cloud-init
sudo systemctl disable cloud-init
sudo systemctl disable --now unattended-upgrades
#
sudo apt install git net-tools vim htop lm-sensors nmap dos2unix iptables-persistent -y
#
echo ""
echo "##################################"
echo "## Welcome to Ghost Node Nation ##"
echo "##################################"

echo ""
echo "Download Github Project"
sudo git clone https://github.com/greycitizen/ghostnodes.git /root/nodenation
sudo find /root/nodenation/ -type f -name "*.sh" -print0 | xargs -0 dos2unix

echo " Changing permition to scripts: "
echo ""
sudo find /root/nodenation/ -name "*.sh" -type f -print0 | xargs -0 chmod +x

# Execute the Menu:
echo "###########################################"
echo "############ Make Your Ghost ##############"
echo "###########################################"
echo ""

echo "##################################"
echo " 1 - Install Halfin Node"
echo " 2 - Install Satoshi Node"
echo " 3 - Install Nick Node"
echo " 4 - Install Craig Node"
echo " 5 or another option - Out"
echo "##################################"
echo ""
read -p "Choose your pill: " escolha </dev/tty
echo ""

pasta1="/root/nodenation/"

case $escolha in

    1)
        echo ""
	echo "#################################"
	echo "Running Halfin Node..."
	echo ""
	echo "#################################"
    echo "#### What is your equipment? ####"
	echo "#################################"
	echo ""

	Ubuntu Server installed on:

	[1] RaspBerry Pi + Dongle Wifi
	[2] Raspberry Pi no Dongle
	[3] Banana Pi Zero 
	[4] Orange Pi Zero 3 + Dongle
	#################################
	"
	pasta2="/root/halfin/"
        read -p "Choose your config: " TIPO </dev/tty
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

	echo ""
	echo "##########################################"
	echo "######## Instalando Satoshi Node #########"
	echo "##########################################"
	echo ""

	satoshi=$pasta1"satoshi/script_s.sh"

        if [ -f "$satoshi" ]; then
            echo "Instalar o Satoshi Node..."
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
            echo "######################################"
	    echo "#### News coming soon for Nick... ####"
            echo "######################################"
            exit 1
        fi
        ;;
    4)
        if [ -f "/craig/script_c.sh" ]; then
            echo "Fooling Craig Node..."
            /bin/bash /craig/script_c.sh </dev/tty
        else
            echo "#######################################"
	        echo "##### Erro: Fooling Craig Node... #####"
            echo "#######################################"
            exit 1
        fi
        ;;
    *)
        echo "Nothing to do!"
	echo ""
 	echo "##### If you want to go back to the installation, type: sudo /root/$newfolder/menu.sh ######"
 	echo ""
        exit 0
        ;;
esac
