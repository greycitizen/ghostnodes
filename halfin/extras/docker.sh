#!/bin/bash
#
# Script para Instalação Docker Halfin Node- v.0.4
#
echo "
#############################################################
####### Escolha os Serviços Extras a serem instalados #######
#############################################################
#############################################################
"
#
echo "Deseja instalar o Servidor Docker e Portainer?
#
Instalar? [s/N]"

read resp
if [ $resp. != 's.' ]; then

echo "Deseja instalar a interface Web? (Cockpit)
#
Instalar? [s/N]"
        read cockpit
        if [ $cockpit. != 's.' ]; then
        exit 0
        fi
                #######
                echo "###### Instalação do Cockpit #######"

                sudo apt install cockpit -y
                sudo systemctl enable cockpit
                sudo systemctl start cockpit

                echo "###### Acesse a Interface Web do Cockpit: http://10.21.21.1:9090 ######"
                exit 0

fi

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#
echo "######### Instalando Docker e Ferramentas ###########"
#
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#
echo "########### Criação e Configuração do Portainer"
#
docker volume create portainer_data
#
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts
#
######
########

echo "Deseja instalar a interface Web? (Cockpit)
                #
                Instalar? [s/N]"
        read cockpit
        if [ $cockpit. != 's.' ]; then
        exit 0
        fi

echo "######### Instalação do Cockpit ##########"

sudo apt install cockpit -y
sudo systemctl enable cockpit
sudo systemctl start cockpit

echo ""
echo "########## Instalação Concluída ##########"
echo ""
echo "###### Acesse a Interface Web do Cockpit: "
echo "########## Através do endereço ###########"
echo ""
echo "######## http://10.21.21.1:9090 ##########"