#!/bin/bash
#
# Script for installation of Bitcoin Core Nodes - Ghost Nodes - Satoshi v.0.3

echo "Updating your Ubuntu Server"
sudo apt update && sudo apt upgrade

# Tools and Dependencies
sudo apt install cron net-tools vim htop lm-sensors nmap tree openssh-server iptraf-ng iw -y

select_version() {
echo ""
echo "###################################"
echo "# Chose your Bitcoin Core Version #"
echo "###################################"
echo ""
echo " Enter your version number"
echo " 28.0"
echo " 27.2"
echo " 25.0"
echo " 0.13.2"
echo ""
read -p " Chose version: " chose
echo ""
}

select_arch() {
echo "###################################"
echo "###### What your Architecture #######"
echo "###################################"
echo ""
echo " [1] Ubuntu Server x86 - PC"
echo " [2] Raspberry Pi - Arm64"
echo " [3] Apple - Darwin"
echo " [4] Riscv64 - Architecture"
echo " [5] Exit"
echo ""

######### Installation for Bitcoin.Org on Ubuntu #########
        v="bitcoin-$chose"
        p="bitcoin-core-$chose"

read -p " Chose Architecture (1 - 4): " arq
case $arq in
        1)
        vers=$v"-x86_64-linux-gnu"
        ;;
        2)
        vers=$v"-arm-linux-gnueabihf"
        ;;
        3)
        vers=$v"-arm64-apple-darwin"
        ;;
        4)
        vers=$v"-riscv64-linux-gnu"
        ;;
        *)
        echo " Wrong choice, good by!"
        exit 0
        ;;
esac
}
install_core()  {
#
echo ""
echo "Installing version $v from Bitcoin Core..."

wget -P $HOME/ -c https://bitcoincore.org/bin/$p/$vers.tar.gz
tar xzvf $HOME/$vers.tar.gz
sudo install -m 0755 -o root -g root -t /usr/local/bin $HOME/$v/bin/*

echo ""
echo "############################################"
echo "######## Starting your Bitcoin Node ########"
echo "############################################"
echo ""

bitcoind -daemon

rm -r $v
rm -r $vers.tar.gz

echo ""
echo "######################################################"
echo "#### Bitcoin Core Server Configuration - Complete ####"
echo "######################################################"
echo ""
}

fulcrum_install() {
echo "######################################################"
echo "############# Install Fulcrum Service? ###############"
echo ""
echo "###### Currently the installation of Fulcrum  ########"
echo "################## is not tested #####################"
echo ""
echo " More then 300Gb of extra space"
echo " Is necessary and recomended beyond of Core"
echo " To run the service"
echo ""
echo "######################################################"
echo " Enter 1 to install Fulcrum - Electrum Server"
echo " Enter 2 for don't install Fulcrum"
echo ""

read -p " Enter your choose: " escolha
echo ""

case $escolha in

        1)

#############################################
### Fulcrum
echo "Instalando o Fulcrum - Electrum Server"

sudo apt install libssl-dev
sudo ufw allow 50001/tcp #comment 'allow Fulcrum TCP from anywhere'
sudo ufw allow 50002/tcp #comment 'allow Fulcrum SSL from anywhere'

echo "# Enable ZMQ blockhash notification (for Fulcrum)
zmqpubhashblock=tcp://127.0.0.1:8433" >> $vers/bitcoin.conf

;;
        2)

echo "#####################################################"
echo "### Continuing the Installation..."
echo "#####################################################"
echo ""
echo ""
echo "#####################################################"
echo " Configure Bitcoin service on boot!"
echo " Execute comand: crontab -e"
echo " And add this command to the last line: "
echo ""
echo " @reboot bitcoind -daemon"
echo ""
echo "#####################################################"
echo ""
echo "#####################################################"
echo "############# Congratulations on being ##############"
echo "############## One more Bitcoin Pleb ################"
echo "#####################################################"
echo ""
#
sudo rm -r /root/nodenation

exit 0

        ;;
esac
}
#
#
########## Instala��o via SNAP (n�o recomendado) ##############
#sudo apt install snapd

#sudo snap install bitcoin-core

### Fulcrum
#echo "Instalando o Fulcrum - Electrum Server"

#sudo apt install libssl-dev
#sudo ufw allow 50001/tcp #comment 'allow Fulcrum TCP from anywhere'
#sudo ufw allow 50002/tcp #comment 'allow Fulcrum SSL from anywhere'

#echo "# Enable ZMQ blockhash notification (for Fulcrum)
#zmqpubhashblock=tcp://127.0.0.1:8433" >> /home/$USER/snap/bitcoin-core/common/.bitcoin/bitcoin.conf

#sudo ss -tulpn | grep bitcoin-core.daemon | grep 8433

#https://bitcoin.org/bin/bitcoin-core-27.0/bitcoin-27.0-x86_64-linux-gnu.tar.gz

#bitcoin-core.daemon -datadir=/home/$USER/snap/bitcoin-core/common/.bitcoin
main() {
    select_version
    select_arch
    install_core
    fulcrum_install
}
main
