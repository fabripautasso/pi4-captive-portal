echo "-----STEP 1 - Remove dhcpcd configuration-----"
sudo sed -i '/interface wlan0/d' /etc/dhcpcd.conf
sudo sed -i '/static ip_address=192.168.220.1\/24/d' /etc/dhcpcd.conf
sudo sed -i '/nohook wpa_supplicant/d' /etc/dhcpcd.conf

echo "-----STEP 2 - Rollback port forwarding-----"
sudo sed -i 's/net.ipv4.ip_forward=1.*/#net.ipv4.ip_forward=1/g' /etc/sysctl.conf

echo "-----STEP 3 - Rollback boot configuration-----"

sudo sed -i '/node \/home\/pi\/portal\/api\/app.js/d' /etc/rc.local
sudo sed -i '/nodogsplash/d' /etc/rc.local
sudo sed -i '/iptables-restore < \/etc\/iptables.ipv4.nat/d' /etc/rc.local

sudo sed -i 's/exit 0/bash \/home\/pi\/portal\/check_internet_connection.sh\'$'\nexit 0/g' /etc/rc.local
sudo sed -i 's+bash \/home\/pi\/portal\/check_internet_connection.sh\$+bash \/home\/pi\/portal\/check_internet_connection.sh+g' /etc/rc.local

echo "-----STEP 4 - Rollback complete - The system will reboot-----"
sudo reboot
