#!/bin/sh
#
# Instalation, Configuration and Tools for "Satoshi Node" Jul/2026 0.7.2v

# Verify user root
verify_user() {
    if [ "$EUID" -eq 0 ]; then
        # Verify if executing like sudo
        if [ -z "$SUDO_USER" ]; then
            # If root direct
            echo ""
	    echo "#########################################"
	    echo "## Don't execute this script like root ##"
	    echo "## Enter: exit ##"
	    echo "## and execute with your pleb user ##"
	    echo "#########################################"
	    echo ""
            echo "  cd ~"
            echo "  ./script_s.sh"
            exit 1
        else
            # Sudo mode (elevate comum user)
            echo "Executando com privilégios de root via sudo..."
            return 0
        fi
    else
        # Modo usuário comum
        echo "Executando como usuário comum..."
        return 0
    fi
}

# Parte 1: Verificação inicial
verificar_usuario

# Parte 2: Execução principal do script
sudo mv /root/nodenation/satoshi/scripts/*.sh $HOME/
sudo mv /root/nodenation/satoshi/script_s.sh $HOME/

echo "###############################################"
echo "######### Bitcoin Core Installation ###########"
echo "###############################################"

$HOME/installcore.sh

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
