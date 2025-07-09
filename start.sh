#!/bin/bash
# Start Ghost Nation Script v.01
#
echo "Atualizando seu Servidor Ubuntu"
sudo apt update && sudo apt upgrade
#
# Disabling unnecessary services
sudo systemctl stop cloud-init
sudo systemctl disable cloud-init
sudo systemctl disable --now unattended-upgrades
#
apt install net-tools vim htop lm-sensors nmap dos2unix -y
#
echo ""
echo "##################################"
echo "## Welcome to Ghost Node Nation ##"
echo "##################################"

echo ""
echo "Download Github Project"
sudo git clone https://github.com/greycitizen/ghostnodes.git /root/nodenation
find /root/nodenation/ -type f -name "*.sh" -print0 | xargs -0 dos2unix

echo " Changing permition to scripts: "
echo ""
find /root/nodenation/ -name "*.sh" -type f -print0 | xargs -0 chmod +x

# Execute the Menu:
echo "###########################################"
echo "############ Make Your Ghost ##############"
#echo "########## Execute this command ###########"
echo "###########################################"
echo ""
#echo "sudo /root/nodenation/./menu.sh"
#echo ""

echo "##################################"
echo " 1 - Install Halfin Node"
echo " 2 - Install Satoshi Node"
echo " 3 - Install Nick Node"
echo " 4 - Install Craig Node"
echo " 5 or another option - Out"
echo "##################################"
echo ""
read -p "Choose your pill: " escolha
echo ""

pasta1="/root/nodenation/"

case $escolha in
    1)
            echo "
Running o Halfin Node..."
echo "#################################
        Qual seu equipamento?
#################################"
echo "#################################

Ubuntu Server instalado em:

[1] RaspBerry Pi + Dongle Wifi
[2] Raspberry Pi sem Dongle
[3] Banana Pi Zero
[4] Outro
#################################
"
        read -p "Escolha a sua configura��o: " TIPO
        if [[ "$TIPO" == "1" ]]; then
        git clone https://github.com/greycitizen/ghostnodes.git $pasta1
        $pasta1halfin/./alias.sh
        $pasta1halfin/./script_rasp.sh
        fi
        if [[ "$TIPO" == "3" ]]; then
        curl -sS https://raw.githubusercontent.com/greycitizen/ghostnodes/refs/heads/main/halfin/script_openwrt.sh | bash
        fi
        if [[ "$TIPO" == "4" ]]; then
        curl -sS https://raw.githubusercontent.com/greycitizen/ghostnodes/refs/heads/main/halfin/script_rasp.sh | bash
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
            /bin/bash $satoshi
        else
            echo "Erro: $satoshi n�o encontrado!"
            exit 1
        fi
        ;;
    3)
        if [ -f "/pleb/script_b.sh" ]; then
            echo "Instalar o Satoshi Node..."
            /bin/bash /pleb/script_b.sh
        else
            echo "Erro: /pleb/script_b.sh n�o encontrado!"
            exit 1
        fi
        ;;
    4)
        if [ -f "/pleb/script_b.sh" ]; then
            echo "Enganando o Craig Node..."
            /bin/bash /pleb/script_b.sh
        else
            echo "Erro: /pleb/script_b.sh n�o encontrado!"
            exit 1
        fi
        ;;
    *)
        echo "Saindo sem executar nada."
        exit 0
        ;;
esac
