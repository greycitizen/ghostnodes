#!/bin/bash
# Start Ghost Nation Script v.01
#
echo "Atualizando seu Servidor Ubuntu"
sudo apt update && sudo apt upgrade -y
#
# Disabling unnecessary services
sudo systemctl stop cloud-init
sudo systemctl disable cloud-init
sudo systemctl disable --now unattended-upgrades
#
sudo apt install git net-tools vim htop lm-sensors nmap dos2unix -y
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
            echo "
Running Halfin Node..."
echo "#################################
     What is your equipment?
#################################"
echo "#################################

Ubuntu Server instalado em:

[1] RaspBerry Pi + Dongle Wifi
[2] Raspberry Pi sem Dongle
[3] Banana Pi Zero 
[4] Orange Pi Zero 3 + Dongle
#################################
"
	pasta2="/root/halfin/"
        read -p "Choose your config: " TIPO </dev/tty
        if [[ "$TIPO" == "1" ]]; then
	newfolder="halfin"
        #git clone https://github.com/greycitizen/ghostnodes.git $pasta1
        $pasta2./alias.sh </dev/tty
        $pasta2./script_rasp.sh </dev/tty
        fi
        if [[ "$TIPO" == "3" ]]; then
        curl -sS https://raw.githubusercontent.com/greycitizen/ghostnodes/refs/heads/main/halfin/script_openwrt.sh | bash
        fi
	
        if [[ "$TIPO" == "4" ]]; then
	newfolder="halfin"
 
 	find $pasta2 -type f -name "*.sh" -print0 | xargs -0 dos2unix
	echo " Changing permition to scripts: "
	echo ""
	find $pasta2 -name "*.sh" -type f -print0 | xargs -0 chmod +x
 
  	mv $pasta1'halfin' /root/
        #git clone https://github.com/greycitizen/ghostnodes.git $pasta1
        $pasta2./alias.sh </dev/tty
        $pasta2./script_orange3.sh </dev/tty
        fi
	
        if [[ "$TIPO" == "2" ]]; then
        echo "Script em fase de testes"
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
            /bin/bash $satoshi </dev/tty
        else
            echo "Erro: $satoshi n�o encontrado!"
            exit 1
        fi
        ;;
    3)
        if [ -f "/pleb/script_b.sh" ]; then
            echo "Instalar o Satoshi Node..."
            /bin/bash /pleb/script_b.sh </dev/tty
        else
            echo "Erro: /pleb/script_b.sh n�o encontrado!"
            exit 1
        fi
        ;;
    4)
        if [ -f "/pleb/script_b.sh" ]; then
            echo "Enganando o Craig Node..."
            /bin/bash /pleb/script_b.sh </dev/tty
        else
            echo "Erro: /pleb/script_b.sh n�o encontrado!"
            exit 1
        fi
        ;;
    *)
        echo "Saindo sem executar nada."
	echo ""
 	echo "##### Caso queira voltar a instalação digite: sudo /root/$newfolder/menu.sh ######"
 	echo ""
        exit 0
        ;;
esac
