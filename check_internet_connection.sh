#!/bin/bash
sudo systemctl stop dnsmasq.service
sleep 60
isInternetOn=`ping -c 1 -q google.com >&/dev/null; echo $?`
if [ $isInternetOn -ne 0 ]
then
  echo "Internet connection was not established"
  sudo sed -i '/node \/home\/pi\/portal\/api\/app.js/d' /etc/rc.local
  sudo sed -i '/nodogsplash/d' /etc/rc.local
  sudo sed -i '/iptables-restore < \/etc\/iptables.ipv4.nat/d' /etc/rc.local
  sudo sed -i '/interface wlan0/d' /etc/dhcpcd.conf
  sudo sed -i '/static ip_address=192.168.220.1\/24/d' /etc/dhcpcd.conf
  sudo sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf
  sudo sed -i '/bash \/home\/pi\/portal\/check_internet_connection.sh/d' /etc/rc.local
  /home/pi/portal/start_as_access_point.sh
fi

if [ $isInternetOn -eq 0 ]
then
  echo "----- Remove captive portal-----"
  sudo apt-get remove libmicrohttpd-dev -y
  sudo rm -rf  ~/nodogsplash
  sudo rm /etc/nodogsplash/nodogsplash.conf
  sudo rm /etc/nodogsplash/htdocs
fi