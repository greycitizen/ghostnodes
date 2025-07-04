#!bin/bash
# Start Ghost Nation Script v.01
#
echo "Atualizando seu Servidor Ubuntu"
sudo apt update && apt dist-upgrade -y
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
echo "########## Execute this command ###########"
echo "###########################################"
echo ""
echo "sudo /root/nodenation/./menu.sh"
echo ""
