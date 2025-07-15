#!/bin/bash
#
#
#
echo ""
echo "####################################"
echo "## Configura��o Ativa do Iptables ##"
echo "####################################"
echo ""
iptables -t nat -L -n -v

echo ""
echo "####################################"
echo "######## Rotas e Interfaces ########"
echo "####################################"
echo ""
ip route show

echo ""
echo "####################################"
echo "### Teste de Internet via Bridge ###"
echo "####################################"
echo ""
ping 8.8.8.8 -c 3