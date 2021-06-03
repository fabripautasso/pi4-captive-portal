#!/bin/bash
echo "-----STEP 1 - System Update-----"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "-----STEP 2 - hostapd and dnsmasq installation-----"
sudo apt-get install hostapd dnsmasq -y

echo "-----STEP 3 - Stop hostapd and dnsmasq-----"
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

echo "-----STEP 4 - Captive portal installation-----"

sudo apt install  libmicrohttpd-dev -y

cd ~
git clone https://github.com/nodogsplash/nodogsplash.git

cd ~/nodogsplash
make
sudo make install

echo "-----STEP 5 - Update dhcpcd to take control of the wlan0 interface-----"
sudo cat <<EOF | sudo tee -a /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.220.1/24
nohook wpa_supplicant
EOF

sudo systemctl restart dhcpcd

echo "-----STEP 6 - Creating new hostapd configuration-----"
sudo cat <<EOF | sudo tee -a /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211

hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=0
macaddr_acl=0
ignore_broadcast_ssid=0

auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# This is the name of the network
ssid=pi-portal-ap
# The network passphrase
wpa_passphrase=wifiappoc
EOF

echo "-----STEP 7 - Update hostapd default path-----"
sudo sed -i 's/#DAEMON_CONF.*/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g' /etc/default/hostapd

echo "-----STEP 8 - Update dnsmasq configuration-----"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

sudo cat <<EOF | sudo tee -a /etc/dnsmasq.conf
interface=wlan0       # Use interface wlan0
server=1.1.1.1       # Use Cloudflare DNS
address=/#/123.123.123.123
except-interface=lo
dhcp-range=192.168.220.50,192.168.220.150,12h # IP range and lease time
EOF

echo "-----STEP 9 - Enable port forwarding-----"
sudo sed -i 's/#net.ipv4.ip_forward=1.*/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

echo "-----STEP 10 - Update IP Tables-----"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo sed -i 's/exit 0/iptables-restore < \/etc\/iptables.ipv4.nat\'$'\nexit 0/g' /etc/rc.local

echo "-----STEP 11 - Start hostapd and dnsmasq-----"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo service dnsmasq start

echo "-----STEP 12 - Captive portal configuration-----"

sudo cat <<EOF | sudo tee -a /etc/nodogsplash/nodogsplash.conf
GatewayInterface wlan0
GatewayAddress 192.168.220.1
MaxClients 250
AuthIdleTimeout 480
EOF

sudo nodogsplash

sudo sed -i 's/exit 0/nodogsplash\'$'\nexit 0/g' /etc/rc.local

sudo cp /home/pi/portal/captive-portal/* /etc/nodogsplash/htdocs
sudo mv /etc/nodogsplash/htdocs/login.html /etc/nodogsplash/htdocs/splash.html

echo "-----STEP 13 - Configure API-----"
sudo sed -i 's/exit 0/node \/home\/pi\/portal\/api\/app.js\'$'\nexit 0/g' /etc/rc.local
sudo sed -i 's/FirewallRule allow tcp port 443/FirewallRule allow tcp port 443\'$'\nFirewallRule allow tcp port 3000/g' /etc/nodogsplash/nodogsplash.conf

echo "-----STEP 14 - Backup wpa_supplicant configuration-----"
sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.orig

echo "-----STEP 15 - Installation complete - The system will reboot-----"
sudo reboot
