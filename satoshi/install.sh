#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Ghost Node Nation — Satoshi Node Installer            ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CORE_LIB="${SCRIPT_DIR}/../lib/core_lib.sh"
GLOBALS="${SCRIPT_DIR}/../var/globals.env"

if [ -f "$CORE_LIB" ]; then source "$CORE_LIB"; else echo -e "\e[31mErro: core_lib.sh não encontrado\e[0m"; exit 1; fi
if [ -f "$GLOBALS" ]; then source "$GLOBALS"; fi

init_state

# ==============================================================================
# 1. VERIFICAÇÃO DE SISTEMA E ARQUITETURA
# ==============================================================================
verificar_sistema() {
    header
    section "Verificação de Hardware e Sistema"
    
    # OS
    step_info "Sistema Operacional detectado: ${BOLD}${OS_NAME}${RESET}"
    
    # Arquitetura
    step_info "Arquitetura detectada: ${BOLD}${ARCH}${RESET}"
    
    case "$ARCH" in
        x86_64) BTC_ARCH="x86_64-linux-gnu" ;;
        aarch64) BTC_ARCH="aarch64-linux-gnu" ;;
        armv7l) BTC_ARCH="arm-linux-gnueabihf" ;;
        riscv64) BTC_ARCH="riscv64-linux-gnu" ;;
        *) 
            step_err "Arquitetura não suportada nativamente: $ARCH"
            confirm "Deseja continuar mesmo assim?" || exit 1
            BTC_ARCH="$ARCH"
            ;;
    esac
    step_ok "Binário correspondente: ${BOLD}${BTC_ARCH}${RESET}"
    echo ""
    press_enter
}

# ==============================================================================
# 2. ESCOLHA DE SERVIÇO E VERSÃO
# ==============================================================================
escolher_servico() {
    header
    section "Seleção do Serviço Bitcoin"
    echo ""
    printf "  ${BOLD}[1]${RESET} Bitcoin Core (Oficial)\n"
    printf "  ${BOLD}[2]${RESET} Bitcoin Knots (Avançado)\n"
    echo ""
    read -p "  Opção: " SRV_OPT
    
    case "$SRV_OPT" in
        1) BTC_SERVICE="core" ;;
        2) BTC_SERVICE="knots" ;;
        *) step_err "Opção inválida"; sleep 1; escolher_servico; return ;;
    esac
    
    header
    section "Seleção da Versão ($BTC_SERVICE)"
    echo ""
    printf "  ${BOLD}[1]${RESET} 28.0 (Recomendado)\n"
    printf "  ${BOLD}[2]${RESET} 27.2\n"
    printf "  ${BOLD}[3]${RESET} 25.0\n"
    printf "  ${BOLD}[4]${RESET} Digitar versão manualmente\n"
    echo ""
    read -p "  Opção: " VER_OPT
    
    case "$VER_OPT" in
        1) BTC_VERSION="28.0" ;;
        2) BTC_VERSION="27.2" ;;
        3) BTC_VERSION="25.0" ;;
        4) 
           echo ""
           read -p "  Digite a versão (ex: 24.0.1): " BTC_VERSION
           ;;
        *) step_err "Opção inválida"; sleep 1; escolher_servico; return ;;
    esac
}

# ==============================================================================
# 3. INSTALAÇÃO
# ==============================================================================
instalar_bitcoin() {
    header
    section "Instalação do Satoshi Node"
    
    local BTC_URL=""
    local FILE_EXT="tar.gz"
    local FOLDER_NAME="bitcoin-${BTC_VERSION}"
    local DOWNLOAD_FILE="${FOLDER_NAME}-${BTC_ARCH}.${FILE_EXT}"

    if [ "$BTC_SERVICE" = "core" ]; then
        BTC_URL="https://bitcoincore.org/bin/bitcoin-core-${BTC_VERSION}/${DOWNLOAD_FILE}"
    elif [ "$BTC_SERVICE" = "knots" ]; then
        # Exemplo Knots URL
        BTC_URL="https://bitcoinknots.org/files/28.x/${BTC_VERSION}/${DOWNLOAD_FILE}"
    fi

    step_info "Criando diretórios em: ${BTC_DATA_DIR}"
    mkdir -p "${BTC_DATA_DIR}"
    
    step_info "Baixando ${BTC_SERVICE} v${BTC_VERSION}..."
    echo "  URL: $BTC_URL"
    if wget -q --show-progress -O "/tmp/${DOWNLOAD_FILE}" "$BTC_URL"; then
        step_ok "Download concluído"
    else
        step_err "Falha ao baixar do endereço acima. Verifique a versão/arquitetura."
        rm -f "/tmp/${DOWNLOAD_FILE}"
        press_enter
        exit 1
    fi
    
    step_info "Extraindo..."
    tar -xzf "/tmp/${DOWNLOAD_FILE}" -C "/tmp/"
    
    step_info "Instalando os binários em /usr/local/bin..."
    sudo install -m 0755 -o root -g root -t /usr/local/bin /tmp/${FOLDER_NAME}/bin/*
    
    rm -rf "/tmp/${FOLDER_NAME}" "/tmp/${DOWNLOAD_FILE}"
    step_ok "Instalação dos binários concluída"
    
    # Criar serviço systemd para iniciar juntamente com o sistema
    step_info "Configurando ${BTC_SERVICE} como um serviço do sistema (systemd)..."
    cat <<EOF | sudo tee /etc/systemd/system/bitcoind.service > /dev/null
[Unit]
Description=Bitcoin daemon
After=network-online.target

[Service]
ExecStart=/usr/local/bin/bitcoind -daemonwait -datadir=${BTC_DATA_DIR}
Type=forking
User=${GHOST_USER}
Group=${GHOST_USER}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    local SVC_NAME="bitcoind"
    
    echo ""
    if confirm "Deseja habilitar e iniciar o bitcoind agora?"; then
        sudo systemctl enable --now $SVC_NAME
        step_ok "Serviço bitcoind ativado e iniciado!"
    else
        step_warn "Você pode iniciá-lo futuramente com: sudo systemctl start bitcoind"
    fi
    
    echo ""
    step_ok "${BOLD}Parabéns por rodar seu Node!${RESET}"
    press_enter
}

# ==============================================================================
# MENU PRINCIPAL DO INSTALADOR SATOSHI
# ==============================================================================
show_satoshi_menu() {
    header
    section "Satoshi Node (Bitcoin) - Instalador"
    
    # Busca status para retomada
    S1=$(state_get "satoshi_step1")
    S2=$(state_get "satoshi_step2")
    
    badge() {
        if [ "$1" = "1" ]; then printf "${GREEN}${BOLD}[✔ concluída]${RESET}"
        else printf "${DIM}[pendente]${RESET}"
        fi
    }
    
    printf "  ${BOLD}[1]${RESET} Verificação de Sistema + Serviço  %b\n" "$(badge $S1)"
    printf "  ${BOLD}[2]${RESET} Download, Instalação e Serviço    %b\n" "$(badge $S2)"
    echo ""
    printf "  ${BOLD}[a]${RESET} Executar Passos em Sequência\n"
    printf "  ${BOLD}[x]${RESET} Desinstalar Bitcoin\n"
    echo ""
    sep
    printf "  ${BOLD}[0]${RESET} Voltar ao Menu Principal\n"
    sep
    echo ""
    read -p "  Opção: " OPT
    
    case "$OPT" in
        1)
            verificar_sistema
            escolher_servico
            state_set "satoshi_step1" "1"
            show_satoshi_menu
            ;;
        2)
            if [ "$(state_get satoshi_step1)" != "1" ]; then
                step_warn "Faça a Etapa 1 primeiro."
                press_enter; show_satoshi_menu; return
            fi
            instalar_bitcoin
            state_set "satoshi_step2" "1"
            show_satoshi_menu
            ;;
        a|A)
            verificar_sistema
            escolher_servico
            state_set "satoshi_step1" "1"
            instalar_bitcoin
            state_set "satoshi_step2" "1"
            show_satoshi_menu
            ;;
        x|X)
            if confirm "TEM CERTEZA QUE DESEJA APAGAR OS BINÁRIOS DO BITCOIN?"; then
                sudo rm -f /usr/local/bin/bitcoin* /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli /usr/local/bin/bitcoin-tx /usr/local/bin/bitcoin-wallet
                sudo systemctl disable --now bitcoind 2>/dev/null || true
                sudo rm -f /etc/systemd/system/bitcoind.service
                sudo systemctl daemon-reload
                state_set "satoshi_step1" "0"
                state_set "satoshi_step2" "0"
                step_ok "Binários e serviço removidos. Dados preservados em ${BTC_DATA_DIR}"
            fi
            press_enter
            show_satoshi_menu
            ;;
        0)
            exit 0
            ;;
        *)
            step_err "Opção inválida"; sleep 1; show_satoshi_menu
            ;;
    esac
}

show_satoshi_menu
