#!/bin/bash
#
# Script para cria��o de regras IPtables para Halfin Node- v.0.1 (IP Forward)
#

echo ""
echo "#############################################"
echo "######## Cria��o das regras Firewall ########"
echo "#############################################"
echo ""

echo 1 > /proc/sys/net/ipv4/ip_forward

# Detectar interface WAN (se necess�rio)
WAN_IFACE=$(ip route | grep default | awk '{print $5}')

#WAN_IFACE=wan1
# Reaplicar regras NAT
sudo iptables -t nat -F
sudo iptables -F

sudo iptables -t nat -A POSTROUTING -o "$WAN_IFACE" -j MASQUERADE
sudo iptables -A FORWARD -i "$WAN_IFACE" -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i br0 -o "$WAN_IFACE" -j ACCEPT

# Salvar regras para persist�ncia
sudo iptables-save > /etc/iptables.rules

# Criar script de restaura��o em boot
cat <<EOF | sudo tee /etc/network/if-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF

sudo chmod +x /etc/network/if-up.d/iptables