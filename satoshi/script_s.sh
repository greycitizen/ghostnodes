#!/bin/sh
#
# Instalation, Configuration and Tools for "Satoshi Node" Jul/2026 0.7.2v

sudo mv /root/nodenation/satoshi/scripts/*.sh /home/pleb/
sudo mv /root/nodenation/satoshi/script_s.sh /home/pleb/

# Verificação de segurança: bloqueia qualquer execução com privilégios
if [ "$EUID" -eq 0 ] || [ -n "$SUDO_USER" ] || [ -n "$SUDO_UID" ] || pstree -ps $$ | grep -q 'sudo'; then
            echo ""
	    echo "#########################################"
	    echo "## Don't execute this script like root ##"
	    echo "## Enter: exit ##"
	    echo "## and execute this with your pleb user ##"
	    echo "#########################################"
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

echo "##### Aliases #####"
echo '# Now ls be colors.
alias ls="ls -la --color"
# IP detailed
alias ip="ip -c -br -a"
# Otimized Update
alias update="sudo apt update && sudo apt upgrade"
# Checking Ports
alias ports="sudo netstat -tulanp"
# Files Size
alias filesize="du -sh * | sort -h"
# Last prompt
alias gh="history|grep ''"
# ?
alias nf="neofetch"
# cd ..
alias ..="cd .."
#
alias c="clear"
# VIM
alias vi="vim"
# Sudo
alias root="sudo -i"
#
' >> $HOME/.bash_aliases

echo ""
echo "#########################"
echo " Execute: source .bashrc "
echo ""

exit 0
