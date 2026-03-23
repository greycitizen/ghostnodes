#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  halfin/pre_install.sh — Pré-Instalação Halfin Node          ║
# ║  Hardware: OrangePi Zero 3 — Debian Bookworm arm64           ║
# ║  Ghost Node Nation v0.13                                     ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Chamado por: nodenation → launch_subproject → pre_install
# Recebe via export: GN_ROOT, GN_USER, GN_HW_*, GN_INSTALL_MODE
#
# O que este script faz (nesta ordem):
#   1. Cria usuário pleb com senha padrão
#   2. Configura sources.list Debian oficial
#   3. Remove pacotes e lista Docker conflitantes
#   4. Define hostname
#   5. Atualiza o sistema
#   6. Instala ferramentas necessárias
#   7. Renomeia interface wlx → wlan1 se necessário (alias.sh)
#   8. Remove autologin e usuário orangepi
#   9. Chama script_orange3.sh se disponível
#

# ── Biblioteca modular ────────────────────────────────────────────────────────
# Tenta carregar a lib; se não disponível, define UI mínima inline
_GN_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_GN_FIND="$_GN_SELF"
while [ ! -d "${_GN_FIND}/lib" ] && [ "$_GN_FIND" != "/" ]; do
    _GN_FIND="$(dirname "$_GN_FIND")"
done

if [ -f "${_GN_FIND}/halfin/lib/init.sh" ]; then
    source "${_GN_FIND}/halfin/lib/init.sh"
elif [ -f "${_GN_FIND}/lib/init.sh" ]; then
    source "${_GN_FIND}/lib/init.sh"
else
    # UI mínima — permite rodar sem a lib instalada
    BOLD="\e[1m"; RESET="\e[0m"; DIM="\e[2m"
    GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; CYAN="\e[36m"; WHITE="\e[97m"
    CHECK="${GREEN}✔${RESET}"; CROSS="${RED}✘${RESET}"
    WARN="${YELLOW}⚠${RESET}"; ARROW="${CYAN}▶${RESET}"; BULLET="${DIM}•${RESET}"
    step_ok()   { printf "  ${CHECK} ${WHITE}%s${RESET}\n" "$1"; }
    step_warn() { printf "  ${WARN}  ${YELLOW}%s${RESET}\n" "$1"; }
    step_err()  { printf "  ${CROSS} ${RED}%s${RESET}\n" "$1"; }
    step_info() { printf "  ${ARROW} ${DIM}%s${RESET}\n" "$1"; }
    sep()       { printf "${DIM}  ──────────────────────────────────────────────────────────────${RESET}\n"; }
    sep_thin()  { printf "${DIM}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}\n"; }
    section()   { echo ""; printf "${BOLD}\e[35m  ┌─ %s${RESET}\n" "$1"; sep_thin; }
    press_enter(){ echo ""; printf "  ${DIM}[ ENTER para continuar ]${RESET}"; read -r; }
    confirm()   {
        printf "\n  ${YELLOW}?${RESET} %s [S/n]: " "$1"; read -r R; R="${R:-s}"
        [[ "$R" =~ ^[sS]$ ]]
    }
fi

# ── Verificação de root ───────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    printf "\n  ${RED}[ERRO]${RESET} Execute como root: ${BOLD}sudo bash %s${RESET}\n\n" "$0"
    exit 1
fi

# ── Variáveis locais com fallback ─────────────────────────────────────────────
GN_USER="${GN_USER:-pleb}"
GN_ROOT="${GN_ROOT:-/home/${GN_USER}/nodenation}"
HALFIN_DIR="${HALFIN_DIR:-${GN_ROOT}/halfin}"
GN_DEFAULT_PASSWORD="${GN_DEFAULT_PASSWORD:-Mudar123}"
GN_HOSTNAME="${GN_HOSTNAME:-halfin}"
GN_LEGACY_USER="${GN_LEGACY_USER:-orangepi}"
PLEB_HOME="/home/${GN_USER}"

# Arquivo de estado local desta pré-instalação
PRE_STATE="${GN_ROOT}/var/preinstall_halfin.state"
mkdir -p "${GN_ROOT}/var" 2>/dev/null || true

# Funções de estado
_state_get() { grep -m1 "^${1}=" "$PRE_STATE" 2>/dev/null | cut -d= -f2 || echo "0"; }
_state_set() {
    grep -q "^${1}=" "$PRE_STATE" 2>/dev/null \
        && sed -i "s/^${1}=.*/${1}=${2}/" "$PRE_STATE" \
        || echo "${1}=${2}" >> "$PRE_STATE"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 1 — Usuário pleb
# ══════════════════════════════════════════════════════════════════════════════
etapa_usuario() {
    section "👤  Etapa 1 — Usuário ${GN_USER}"
    echo ""

    if id "$GN_USER" &>/dev/null; then
        step_ok "Usuário '${GN_USER}' já existe — pulando criação"
    else
        step_info "Criando usuário '${GN_USER}'..."

        # adduser sem senha interativa
        adduser --disabled-password --gecos "" "$GN_USER"

        # Define senha padrão
        echo "${GN_USER}:${GN_DEFAULT_PASSWORD}" | chpasswd

        # Adiciona ao grupo sudo
        usermod -aG sudo "$GN_USER"

        step_ok "Usuário '${GN_USER}' criado"
        step_warn "Senha padrão: ${BOLD}${GN_DEFAULT_PASSWORD}${RESET} — altere após o primeiro login!"
    fi

    # Garante que o home existe com permissões corretas
    mkdir -p "$PLEB_HOME"
    chown "${GN_USER}:${GN_USER}" "$PLEB_HOME"

    _state_set "etapa_usuario" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 2 — Sources.list Debian oficial
# ══════════════════════════════════════════════════════════════════════════════
etapa_sourcelist() {
    section "📦  Etapa 2 — Sources.list Debian Bookworm"
    echo ""

    # Verifica se já está configurado com repositórios Debian oficiais
    if grep -q "deb.debian.org/debian bookworm" /etc/apt/sources.list 2>/dev/null \
       && ! grep -qiE "ubuntu|armbian|orangepi-repo" /etc/apt/sources.list 2>/dev/null; then
        step_ok "sources.list já está com repositórios Debian oficiais"
        _state_set "etapa_sourcelist" "1"
        return 0
    fi

    step_info "Fazendo backup: /etc/apt/sources.list.bak"
    cp /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true

    step_info "Escrevendo novo sources.list..."

    # tee em vez de sudo echo > (que não funciona com redirect e sudo)
    tee /etc/apt/sources.list > /dev/null << 'SOURCES'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware

deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
#deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
SOURCES

    step_ok "sources.list atualizado"

    # Remove lista Docker se existir (conflita com o projeto)
    if [ -f /etc/apt/sources.list.d/docker.list ]; then
        rm -f /etc/apt/sources.list.d/docker.list
        step_ok "docker.list removido de sources.list.d/"
    fi

    _state_set "etapa_sourcelist" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 3 — Remove pacotes Docker conflitantes
# ══════════════════════════════════════════════════════════════════════════════
etapa_remove_docker() {
    section "🐋  Etapa 3 — Remoção de Pacotes Docker Conflitantes"
    echo ""

    local DOCKER_PKGS="docker.io docker-doc docker-compose podman-docker containerd runc"
    local FOUND=""

    for PKG in $DOCKER_PKGS; do
        dpkg -l "$PKG" 2>/dev/null | grep -q "^ii" && FOUND="$FOUND $PKG" || true
    done

    if [ -z "$FOUND" ]; then
        step_ok "Nenhum pacote Docker conflitante instalado"
    else
        step_warn "Pacotes encontrados:${YELLOW}${FOUND}${RESET}"
        step_info "Removendo..."
        set +e
        DEBIAN_FRONTEND=noninteractive apt-get remove -y $FOUND 2>/dev/null
        set -e
        step_ok "Pacotes removidos"
    fi

    _state_set "etapa_remove_docker" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 4 — Hostname
# ══════════════════════════════════════════════════════════════════════════════
etapa_hostname() {
    section "🏷   Etapa 4 — Hostname"
    echo ""

    local CURRENT
    CURRENT=$(hostname 2>/dev/null || echo "")

    if [ "$CURRENT" = "$GN_HOSTNAME" ]; then
        step_ok "Hostname já configurado: ${BOLD}${GN_HOSTNAME}${RESET}"
    else
        step_info "Alterando hostname: '${CURRENT}' → '${GN_HOSTNAME}'"
        echo "$GN_HOSTNAME" > /etc/hostname
        hostname "$GN_HOSTNAME"

        # Atualiza /etc/hosts sem duplicar
        if grep -q "127.0.1.1" /etc/hosts; then
            sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t${GN_HOSTNAME}/" /etc/hosts
        else
            echo "127.0.1.1	${GN_HOSTNAME}" >> /etc/hosts
        fi

        step_ok "Hostname definido: ${BOLD}${GN_HOSTNAME}${RESET}"
    fi

    _state_set "etapa_hostname" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 5 — Atualização do sistema
# ══════════════════════════════════════════════════════════════════════════════
etapa_update() {
    section "🔄  Etapa 5 — Atualização do Sistema"
    echo ""

    step_info "apt-get update..."
    set +e
    DEBIAN_FRONTEND=noninteractive apt-get update -q 2>&1 \
        | while IFS= read -r L; do printf "  ${DIM}%s${RESET}\n" "$L"; done

    step_info "apt-get upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 2>&1 \
        | while IFS= read -r L; do
            echo "$L" | grep -qiE "^E:|error|fatal" \
                && printf "  ${RED}%s${RESET}\n" "$L" \
                || printf "  ${DIM}%s${RESET}\n" "$L"
          done
    set -e

    step_ok "Sistema atualizado"
    _state_set "etapa_update" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 6 — Instalação de ferramentas
# ══════════════════════════════════════════════════════════════════════════════
etapa_ferramentas() {
    section "🛠   Etapa 6 — Instalação de Ferramentas"
    echo ""

    local PKGS="git htop vim net-tools nmap tree lm-sensors dos2unix \
                openssh-server iptraf-ng hostapd iptables iw traceroute \
                bridge-utils iptables-persistent btop sqlite3 \
                ca-certificates curl gnupg lsb-release"

    local MISSING=""
    for PKG in $PKGS; do
        dpkg -l "$PKG" 2>/dev/null | grep -q "^ii" \
            || MISSING="$MISSING $PKG"
    done

    if [ -z "$MISSING" ]; then
        step_ok "Todos os pacotes já instalados"
        _state_set "etapa_ferramentas" "1"
        return 0
    fi

    step_info "Pacotes a instalar:${YELLOW}${MISSING}${RESET}"
    echo ""

    local PKG_OK=0 PKG_FAIL=0 PKG_FAIL_LIST=""

    # Instala um por vez para isolar falhas
    for PKG in $MISSING; do
        set +e
        DEBIAN_FRONTEND=noninteractive apt-get install -y "$PKG" -q \
            2>&1 | tail -3 | while IFS= read -r L; do
                echo "$L" | grep -qiE "^E:|error|fatal" \
                    && printf "    ${RED}%s${RESET}\n" "$L" \
                    || printf "    ${DIM}%s${RESET}\n" "$L"
            done
        local RC=${PIPESTATUS[0]}
        set -e

        if [ "$RC" -eq 0 ]; then
            step_ok "$PKG"
            PKG_OK=$((PKG_OK+1))
        else
            step_warn "$PKG — falhou (RC=$RC)"
            PKG_FAIL=$((PKG_FAIL+1))
            PKG_FAIL_LIST="$PKG_FAIL_LIST $PKG"
            # Tenta recuperar dpkg
            dpkg --configure -a 2>/dev/null || true
            apt-get install -f -y -q 2>/dev/null || true
        fi
    done

    echo ""
    sep
    step_ok "Instalados: ${PKG_OK}"
    [ "$PKG_FAIL" -gt 0 ] && step_warn "Falharam: ${PKG_FAIL} —${PKG_FAIL_LIST}"

    _state_set "etapa_ferramentas" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 7 — Interface Wi-Fi wlx → wlan1 (usa alias.sh se disponível)
# ══════════════════════════════════════════════════════════════════════════════
etapa_alias_wifi() {
    section "📡  Etapa 7 — Interfaces Wi-Fi"
    echo ""

    # Verifica condição: wlan0 existe E existe interface wlx...
    local TEM_WLAN0=0 IFACE_WLX=""
    while IFS= read -r IFACE; do
        [ "$IFACE" = "wlan0" ]   && TEM_WLAN0=1
        [[ "$IFACE" == wlx* ]]   && IFACE_WLX="$IFACE"
    done < <(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')

    if [ "$TEM_WLAN0" -eq 0 ] || [ -z "$IFACE_WLX" ]; then
        step_info "Condição wlan0 + wlx não atendida — pulando renomeação"
        _state_set "etapa_alias" "1"
        return 0
    fi

    step_warn "Detectado: wlan0 (interna) + ${IFACE_WLX} (externa)"
    step_info "Renomeando ${IFACE_WLX} → wlan1 via regra udev..."

    local MAC RULE_FILE
    MAC=$(cat "/sys/class/net/${IFACE_WLX}/address" 2>/dev/null || echo "")
    RULE_FILE="/etc/udev/rules.d/70-halfin-wlan1.rules"

    if [ -z "$MAC" ]; then
        step_err "Não foi possível ler MAC de ${IFACE_WLX}"
    else
        tee "$RULE_FILE" > /dev/null << UDEV
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${MAC}", NAME="wlan1"
UDEV
        udevadm control --reload 2>/dev/null || true
        udevadm trigger --subsystem-match=net 2>/dev/null || true
        step_ok "Regra udev criada: ${RULE_FILE}"
        step_ok "${IFACE_WLX} (MAC: ${MAC}) → wlan1 após reboot"
    fi

    _state_set "etapa_alias" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 8 — Remove usuário orangepi (legado OrangePi OS)
# ══════════════════════════════════════════════════════════════════════════════
etapa_remove_legado() {
    section "🗑   Etapa 8 — Remoção do Usuário Legado (${GN_LEGACY_USER})"
    echo ""

    if ! id "$GN_LEGACY_USER" &>/dev/null; then
        step_ok "Usuário '${GN_LEGACY_USER}' não existe — nada a fazer"
        _state_set "etapa_remove_legado" "1"
        return 0
    fi

    # Remove overrides de autologin ANTES de matar o usuário
    local GETTY_OVR="/lib/systemd/system/getty@.service.d/override.conf"
    local SERIAL_OVR="/lib/systemd/system/serial-getty@.service.d/override.conf"

    [ -f "$GETTY_OVR" ]  && { rm -f "$GETTY_OVR";  step_ok "Removido: $GETTY_OVR";  }
    [ -f "$SERIAL_OVR" ] && { rm -f "$SERIAL_OVR"; step_ok "Removido: $SERIAL_OVR"; }

    # Encerra processos
    step_info "Encerrando processos de '${GN_LEGACY_USER}'..."
    pkill -9 -u "$GN_LEGACY_USER" 2>/dev/null || true
    sleep 1

    # Remove usuário e home
    step_info "Removendo usuário e home directory..."
    deluser --remove-home "$GN_LEGACY_USER" 2>/dev/null \
        && step_ok "Usuário '${GN_LEGACY_USER}' removido" \
        || step_warn "Falha ao remover — pode ser necessário manualmente"

    systemctl daemon-reload 2>/dev/null || true
    step_ok "systemd recarregado"

    _state_set "etapa_remove_legado" "1"
}

# ══════════════════════════════════════════════════════════════════════════════
# ETAPA 9 — script_orange3.sh (configuração específica do hardware)
# ══════════════════════════════════════════════════════════════════════════════
etapa_orange3() {
    section "🍊  Etapa 9 — Script de Configuração OrangePi (script_orange3.sh)"
    echo ""

    local ORANGE_SCRIPT="${HALFIN_DIR}/script_orange3.sh"

    if [ ! -f "$ORANGE_SCRIPT" ]; then
        step_warn "script_orange3.sh não encontrado em: ${HALFIN_DIR}"
        step_info "Este script realiza configurações específicas do OrangePi Zero 3."
        step_info "Certifique-se que o projeto foi baixado completamente."
        _state_set "etapa_orange3" "skip"
        return 0
    fi

    step_ok "Script encontrado: ${ORANGE_SCRIPT}"
    echo ""

    printf "  ${YELLOW}⚠  Atenção:${RESET} Se a conexão SSH cair durante esta etapa,\n"
    printf "  reconecte com o usuário ${BOLD}${GN_USER}${RESET} e execute:\n"
    printf "  ${CYAN}  sudo bash ${ORANGE_SCRIPT}${RESET}\n\n"

    press_enter

    sep
    bash "$ORANGE_SCRIPT"
    local RC=$?
    sep

    if [ $RC -eq 0 ]; then
        step_ok "script_orange3.sh concluído com sucesso"
        _state_set "etapa_orange3" "1"
    else
        step_warn "script_orange3.sh retornou código $RC"
        _state_set "etapa_orange3" "warn"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# EXECUÇÃO PRINCIPAL
# ══════════════════════════════════════════════════════════════════════════════
main() {
    clear
    printf "${BOLD}\e[36m"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║  Pre-Install — Halfin Node / OrangePi Zero 3              ║"
    printf "  ║  %-60s║\n" "  Ghost Node Nation v0.13 — $(date '+%d/%m/%Y')"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    printf "${RESET}\n"

    echo ""
    printf "  ${DIM}Hardware : ${WHITE}${GN_HW_MODEL:-Detectando...}${RESET}\n"
    printf "  ${DIM}Arch     : ${WHITE}${GN_HW_ARCH:-?}${RESET}\n"
    printf "  ${DIM}SO       : ${WHITE}${GN_HW_OS:-?}${RESET}\n"
    printf "  ${DIM}Usuário  : ${WHITE}${GN_USER}${RESET}\n"
    printf "  ${DIM}Raiz     : ${WHITE}${GN_ROOT}${RESET}\n"
    echo ""
    sep
    echo ""

    # Verifica etapas já concluídas (permite retomar)
    local SKIP_MSG=""
    [ "$(_state_get etapa_usuario)" = "1" ]       && SKIP_MSG="${SKIP_MSG}usuário "
    [ "$(_state_get etapa_sourcelist)" = "1" ]     && SKIP_MSG="${SKIP_MSG}sources "
    [ "$(_state_get etapa_remove_docker)" = "1" ]  && SKIP_MSG="${SKIP_MSG}docker "
    [ "$(_state_get etapa_hostname)" = "1" ]       && SKIP_MSG="${SKIP_MSG}hostname "
    [ "$(_state_get etapa_update)" = "1" ]         && SKIP_MSG="${SKIP_MSG}update "
    [ "$(_state_get etapa_ferramentas)" = "1" ]    && SKIP_MSG="${SKIP_MSG}ferramentas "

    if [ -n "$SKIP_MSG" ]; then
        step_info "Etapas já concluídas (serão puladas): ${SKIP_MSG}"
        echo ""
    fi

    # Executa cada etapa (pula se já concluída)
    [ "$(_state_get etapa_usuario)" != "1" ]      && etapa_usuario
    [ "$(_state_get etapa_sourcelist)" != "1" ]   && etapa_sourcelist
    [ "$(_state_get etapa_remove_docker)" != "1" ] && etapa_remove_docker
    [ "$(_state_get etapa_hostname)" != "1" ]     && etapa_hostname
    [ "$(_state_get etapa_update)" != "1" ]       && etapa_update
    [ "$(_state_get etapa_ferramentas)" != "1" ]  && etapa_ferramentas
    # Alias e orange3 sempre verificam (não são destrutivos)
    etapa_alias_wifi
    etapa_orange3

    # ── Resumo final ──────────────────────────────────────────────────────────
    echo ""
    printf "${BOLD}\e[32m"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║           ✔  Pré-Instalação Concluída!                     ║"
    echo "  ╠══════════════════════════════════════════════════════════════╣"
    printf "  ║  ${RESET}${DIM}%-60b${RESET}${BOLD}\e[32m║\n" "Usuário    : ${GN_USER} (senha: ${GN_DEFAULT_PASSWORD})"
    printf "  ║  ${RESET}${DIM}%-60b${RESET}${BOLD}\e[32m║\n" "Hostname   : ${GN_HOSTNAME}"
    printf "  ║  ${RESET}${DIM}%-60b${RESET}${BOLD}\e[32m║\n" "Projeto    : ${GN_ROOT}"
    echo "  ╠══════════════════════════════════════════════════════════════╣"
    echo "  ║  Próximos passos:                                           ║"
    echo "  ║  • Faça login com o usuário pleb                           ║"
    printf "  ║  • ${RESET}${YELLOW}Altere a senha: passwd${RESET}${BOLD}\e[32m                                ║\n"
    echo "  ║  • Execute: ghostnode                                       ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    printf "${RESET}\n"
}

set +e
main
