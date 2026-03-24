#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  halfin/routing.sh — Firewall / NAT / ip_forward           ║
# ║  Ghost Nodes - NodeNation / Halfin Node  v0.4              ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Biblioteca modular ────────────────────────────────────────────────────────
_GN_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_GN_FIND="$_GN_SELF"
while [ ! -d "${_GN_FIND}/lib" ] && [ "$_GN_FIND" != "/" ]; do
    _GN_FIND="$(dirname "$_GN_FIND")"
done
[ -f "${_GN_FIND}/halfin/lib/init.sh" ] && source "${_GN_FIND}/halfin/lib/init.sh" || {
    BOLD="\e[1m"; RESET="\e[0m"; DIM="\e[2m"
    GREEN="\e[32m"; YELLOW="\e[33m"; RED="\e[31m"; CYAN="\e[36m"; WHITE="\e[97m"
    CHECK="${GREEN}✔${RESET}"; CROSS="${RED}✘${RESET}"; WARN="${YELLOW}⚠${RESET}"; ARROW="${CYAN}▶${RESET}"
    sep()      { printf "${DIM}  ──────────────────────────────────────────────────────────────${RESET}\n"; }
    sep_thin() { printf "${DIM}  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄${RESET}\n"; }
    section()  { echo ""; printf "${BOLD}\e[35m  ┌─ %s${RESET}\n" "$1"; sep_thin; }
    step_ok()  { printf "  ${CHECK} ${WHITE}%s${RESET}\n" "$1"; }
    step_warn(){ printf "  ${WARN}  ${YELLOW}%s${RESET}\n" "$1"; }
    step_err() { printf "  ${CROSS} ${RED}%s${RESET}\n" "$1"; }
    step_info(){ printf "  ${ARROW} ${DIM}%s${RESET}\n" "$1"; }
}

if [ "$EUID" -ne 0 ]; then
    printf "\n  ${RED}[ERRO]${RESET} Execute como root: ${BOLD}sudo bash %s${RESET}\n\n" "$0"
    exit 1
fi

set +e   # Erros em iptables não devem abortar

# ─────────────────────────────────────────────────────────────────────────────
clear
printf "${BOLD}${CYAN}"
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║  Ghost Nodes - NodeNation                                  ║"
echo "  ║  Halfin Node — Firewall / NAT / ip_forward  v0.4          ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
printf "${RESET}\n"

# ── Detecta WAN ───────────────────────────────────────────────────────────────
section "🔍  Detecção da Interface WAN"
echo ""

WAN_IFACE=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
# Descomente para forçar manualmente:
# WAN_IFACE=end0

if [ -z "$WAN_IFACE" ]; then
    step_err "Interface WAN não detectada. Defina WAN_IFACE manualmente no arquivo."
    exit 1
fi
step_ok "Interface WAN: ${BOLD}${WAN_IFACE}${RESET}"

# ── ip_forward persistente ────────────────────────────────────────────────────
section "🔄  ip_forward"
echo ""

echo 1 > /proc/sys/net/ipv4/ip_forward

if ! grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
else
    sed -i 's/^.*net\.ipv4\.ip_forward.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
fi
sysctl -p /etc/sysctl.conf > /dev/null
step_ok "ip_forward ativo e persistente"

# ── Analisa regras iptables atuais ────────────────────────────────────────────
section "📋  Análise das Regras Atuais"
echo ""

NEED_FWD_IN="-A FORWARD -i ${WAN_IFACE} -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT"
NEED_FWD_OUT="-A FORWARD -i br0 -o ${WAN_IFACE} -j ACCEPT"
NEED_NAT="-A POSTROUTING -o ${WAN_IFACE} -j MASQUERADE"

CURRENT_FILTER=$(iptables-save -t filter 2>/dev/null)
CURRENT_NAT=$(iptables-save -t nat 2>/dev/null)

printf "  ${DIM}%-55s  %s${RESET}\n" "Regra necessária" "Status"
sep_thin

FWD_IN_EXISTS=0; FWD_OUT_EXISTS=0; NAT_EXISTS=0

echo "$CURRENT_FILTER" | grep -qF "$NEED_FWD_IN" \
    && { printf "  %-55s ${GREEN}já existe${RESET}\n" "FORWARD ${WAN_IFACE}→br0 ESTABLISHED"; FWD_IN_EXISTS=1; } \
    || printf "  %-55s ${YELLOW}ausente${RESET}\n" "FORWARD ${WAN_IFACE}→br0 ESTABLISHED"

echo "$CURRENT_FILTER" | grep -qF "$NEED_FWD_OUT" \
    && { printf "  %-55s ${GREEN}já existe${RESET}\n" "FORWARD br0→${WAN_IFACE} ACCEPT"; FWD_OUT_EXISTS=1; } \
    || printf "  %-55s ${YELLOW}ausente${RESET}\n" "FORWARD br0→${WAN_IFACE} ACCEPT"

echo "$CURRENT_NAT" | grep -qF "$NEED_NAT" \
    && { printf "  %-55s ${GREEN}já existe${RESET}\n" "NAT POSTROUTING ${WAN_IFACE} MASQUERADE"; NAT_EXISTS=1; } \
    || printf "  %-55s ${YELLOW}ausente${RESET}\n" "NAT POSTROUTING ${WAN_IFACE} MASQUERADE"

# ── Remove conflitos ──────────────────────────────────────────────────────────
section "🧹  Verificação de Conflitos"
echo ""

CONFLICTS=0

# FORWARD DROP/REJECT em WAN ou br0
NUMS=$(iptables -L FORWARD --line-numbers -n 2>/dev/null \
    | awk -v wan="$WAN_IFACE" '/DROP|REJECT/{if($0~wan||$0~"br0") print $1}' | sort -rn)

if [ -n "$NUMS" ]; then
    step_warn "FORWARD bloqueante encontrado — removendo:"
    for NUM in $NUMS; do
        LINE=$(iptables -L FORWARD --line-numbers -n | awk -v n="$NUM" '$1==n{print}')
        printf "     ${RED}#%s: %s${RESET}\n" "$NUM" "$LINE"
        iptables -D FORWARD "$NUM" 2>/dev/null
        CONFLICTS=$((CONFLICTS+1))
    done
    echo ""
fi

# MASQUERADE em outra interface (double-NAT)
DUP_NUMS=$(iptables -t nat -L POSTROUTING --line-numbers -n 2>/dev/null \
    | awk -v wan="$WAN_IFACE" '/MASQUERADE/&&$0!~wan{print $1}' | sort -rn)

if [ -n "$DUP_NUMS" ]; then
    step_warn "MASQUERADE em interface diferente de ${WAN_IFACE}:"
    for NUM in $DUP_NUMS; do
        iptables -t nat -D POSTROUTING "$NUM" 2>/dev/null
        CONFLICTS=$((CONFLICTS+1))
    done
fi

# MASQUERADE duplicado na mesma WAN
MASQ_COUNT=$(iptables -t nat -L POSTROUTING -n 2>/dev/null | grep -c "MASQUERADE" || echo 0)
if [ "$MASQ_COUNT" -gt 1 ]; then
    step_warn "${MASQ_COUNT} MASQUERADE duplicados — limpando POSTROUTING..."
    iptables -t nat -F POSTROUTING
    NAT_EXISTS=0
    CONFLICTS=$((CONFLICTS+1))
fi

[ "$CONFLICTS" -eq 0 ] && step_ok "Nenhum conflito encontrado"

# ── Aplica regras ausentes ────────────────────────────────────────────────────
section "✚  Aplicando Regras Ausentes"
echo ""

ADDED=0
[ "$FWD_IN_EXISTS"  -eq 0 ] && {
    iptables -A FORWARD -i "$WAN_IFACE" -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    step_ok "FORWARD ${WAN_IFACE}→br0 ESTABLISHED"
    ADDED=$((ADDED+1))
}
[ "$FWD_OUT_EXISTS" -eq 0 ] && {
    iptables -A FORWARD -i br0 -o "$WAN_IFACE" -j ACCEPT
    step_ok "FORWARD br0→${WAN_IFACE} ACCEPT"
    ADDED=$((ADDED+1))
}
[ "$NAT_EXISTS"     -eq 0 ] && {
    iptables -t nat -A POSTROUTING -o "$WAN_IFACE" -j MASQUERADE
    step_ok "NAT POSTROUTING ${WAN_IFACE} MASQUERADE"
    ADDED=$((ADDED+1))
}
[ "$ADDED" -eq 0 ] && step_ok "Todas as regras já presentes — nada adicionado"

# ── Persistência ──────────────────────────────────────────────────────────────
section "💾  Persistência"
echo ""

mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4

RESTORE_SCRIPT="/etc/network/if-up.d/iptables-halfin"
tee "$RESTORE_SCRIPT" > /dev/null << 'IPTRESTORE'
#!/bin/sh
# Restaura regras iptables Halfin ao subir interface
[ -f /etc/iptables/rules.v4 ] && iptables-restore < /etc/iptables/rules.v4
IPTRESTORE
chmod +x "$RESTORE_SCRIPT"

step_ok "Regras salvas: /etc/iptables/rules.v4"
step_ok "Script de boot: $RESTORE_SCRIPT"

# ── Resumo ────────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${CYAN}"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Resultado Final — Routing / NAT"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "${RESET}"
printf "  ${DIM}WAN Interface  :${RESET} ${BOLD}%s${RESET}\n"   "$WAN_IFACE"
printf "  ${DIM}ip_forward     :${RESET} ${BOLD}%s${RESET}\n"   "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo '?')"
printf "  ${DIM}Conflitos rem. :${RESET} ${BOLD}%s${RESET}\n"   "$CONFLICTS"
printf "  ${DIM}Regras adicion.:${RESET} ${BOLD}%s${RESET}\n\n" "$ADDED"

printf "  ${BOLD}FORWARD ativo:${RESET}\n"
iptables -L FORWARD --line-numbers -n 2>/dev/null | sed 's/^/    /'
echo ""
printf "  ${BOLD}NAT POSTROUTING:${RESET}\n"
iptables -t nat -L POSTROUTING --line-numbers -n 2>/dev/null | sed 's/^/    /'
echo ""
