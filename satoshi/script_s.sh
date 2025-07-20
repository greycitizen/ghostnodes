#!/bin/sh
#
# Instalation, Configuration and Tools for "Satoshi Node" Jul/2026 0.7.2v

# Verify user root
verify_user() {    # Verifica se estamos rodando como root (EUID=0)
    if [ "$EUID" -eq 0 ]; then
        
        # Tenta determinar se foi através de sudo
        local sudo_context=0
        if [ -n "$SUDO_USER" ]; then
            # Caso padrão: executado com sudo
            sudo_context=1
        elif [ -n "$SUDO_UID" ]; then
            # Alternativa para alguns sistemas
            sudo_context=1
        else
            # Verifica processos pais para detectar 'sudo su'
            if pstree -ps $$ | grep -q 'sudo.*su'; then
                sudo_context=1
            fi
        fi

        if [ "$sudo_context" -eq 1 ]; then
            echo "Executando com privilégios elevados (via sudo)"
            return 0
        else
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
        fi
    else
        # Modo usuário comum
        echo "Executando como usuário comum..."
        return 0
    fi
}

# Parte 1: Verificação inicial
verify_user

# Parte 2: Execução principal do script
sudo mv /root/nodenation/satoshi/scripts/*.sh $HOME/
sudo mv /root/nodenation/satoshi/script_s.sh $HOME/

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
