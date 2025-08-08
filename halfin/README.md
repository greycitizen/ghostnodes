Halfin Node directory

# Halfin - Release 0.1
#### Hadware Details

##### Orange Pi Zero 3

Processor:</br>
Allwinner H618 Quad-Core Cortex-A53

Memory:</br>
1.5 Gb - LPDDR4 

Wi-Fi 5 (dual 2.4Ghz + 5Ghz) + Bluetooth 5.0

MicroSD card:</br>
32Gb Class 10+ (Recommend)

Wi-Fi Dongle:</br>
Extra Wi-Fi (dual 2.4Ghz + 5Ghz) - Ralink MT7601U ( Ralink or Realtek - recommended)

================================================================

##### Applications

	htop - 
	net-tools -
	lm-sensors -
	git - 
	vim -
	nmap - 
	dos2unix - 
	iptables and iptables-persistent - 
	tree - 
	openssh-server -
	iptraf-ng - 
	hostapd - 
	iw -


#### Script's

temp.sh
###### Show CPU and system temperature (continue is a option for realtime monitor - under 65 degrees is normatize)

wifi_connect.sh</br>
###### Script for connection whit options to choose SSID and password

internet-test.sh or routing.sh</br>
###### 2 options for routing connection from WAN to br0 (bridge) for internet compartiment.

relat_sec.sh</br>
###### Script for security relatory geration

radio_ssid.sh</br>
###### Script for visualize wireless networks near

alias.sh</br>
###### For rename the interface wireless and facilitated identification and configurations

lan.sh</br>
###### Script for DHCP Lan configuration in ethernets interfaces</br>

</br>
### Folder: extras

check_c.sh</br>
###### Script unify network checking relatory - Iptables list - ping - traceroute

defaults-debian.conf</br>
###### Config file for fail2ban definitions - local: /etc/fail2ban/jail.d/

docker.sh</br>
###### Instalation script for Docker, Portainer and Cockpit

fail2ban.sh</br>
###### Instalation and basic configuration for service

network_check.sh</br>
###### Scan for up computers in network

pi-hole.sh</br>
###### Instalation for pi-hole server with unbound DNS service

pihole.toml</br>
###### Configuration file for pi-hole in GhostNodes network

sys.sh</br>
###### Monitoring system in realtime or relatory from open connections
