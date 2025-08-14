#!/bin/sh
#
# Instalation, Configuration and Tools for "Satoshi Node" Jul/2026 0.7.2v

sudo mv /root/nodenation/satoshi/scripts/*.sh /home/pleb/
sudo mv /root/nodenation/satoshi/script_s.sh /home/pleb/
sudo mv /root/nodenation/satoshi/scripts/bitcoin.conf /home/pleb/
sudo chown pleb:pleb /home/pleb/*

su pleb

# Verificação de segurança: bloqueia qualquer execução com privilégios
if [ "$EUID" -eq 0 ] || [ -n "$SUDO_USER" ] || [ -n "$SUDO_UID" ] || pstree -ps $$ | grep -q 'sudo'; then
            echo ""
	    echo "#########################################"
	    echo "## Don't execute this script like root ##"
	    echo "## Enter: exit ##"
	    echo "## and execute this with your pleb user ##"
	    echo "#########################################"
    	    echo ""
     	    echo " exit"
	    echo ""
            echo " /home/pleb/./installcore.sh"
	    echo ""
            exit 1     
        fi

# ===============================================
# A PARTIR DAQUI: EXECUÇÃO NORMAL (USUÁRIO COMUM)
# ===============================================	


echo "###############################################"
echo "######### Bitcoin Core Installation ###########"
echo "###############################################"

$HOME/installcore.sh </dev/tty

exit 0

