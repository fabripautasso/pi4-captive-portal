# pi4-captive-portal
## Summary
This project contains the needed scripts to configure a Raspberry Pi4 to:
 - Start the Raspberry Pi as an access point with a captive portal
    - AP SSID: `pi-portal-ap`
    - AP PWD: `wifiappoc`
    - AP IP: `192.168.220.1`
 - When the user connects to the Raspberry Pi network it will be prompted with a login screen
 to put the SSID and PWD of the home wifi network
 - After logged in, the Raspberry Pi will reboot and use the entered info to setup the WI-FI
 - If after the WI-FI setup, the Raspberry Pi doesn't have internet connection, the configuration will
 be rolled back, and the Raspberry Pi will be rebooted as an access point.
 
## Setup
To setup the solution into the Raspberry Pi:
 - Go to the `api/security` directory within the project and follow the steps to generate the certificates
 - ssh into your Raspberry Pi. (You can get you Raspberry Pi ip running `ifconfig` from Pi terminal)
 - create a new directory in `/home/pi` called `portal`
 - Upload all the project files into that folder
 - `cd /home/pi/portal`
 - `./start_as_access_point.sh`
