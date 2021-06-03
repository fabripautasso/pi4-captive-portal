const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const https = require("https")

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.get('/', function (req, res) {
    res.end('Hello world');
})

app.post('/login', function (req, res) {
    fs.writeFile('/etc/wpa_supplicant/wpa_supplicant.conf', 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n' +
        'update_config=1\n' +
        'country=AR\n' +
        '\n' +
        'network={\n' +
        `\tssid="${req.body.ssid}"\n` +
        `\tpsk="${req.body.psw}"\n` +
        '\tkey_mgmt=WPA-PSK\n' +
        '}', function (error) {
        if (error) throw error;
        console.log('File was created successfully.');
    });
    res.status(200).send('Your device is configured and will be rebooted now');

    const { exec } = require('child_process');
    exec('sudo /home/pi/portal/rollback_access_point_setup.sh', (err, stdout, stderr) => {
        if (err) {
            //some err occurred
            console.error(err)
        } else {
            // the *entire* stdout and stderr (buffered)
            console.log(`stdout: ${stdout}`);
            console.log(`stderr: ${stderr}`);
        }
    });
});

const options = {
    key: fs.readFileSync("security/server-portal-key.pem"),
    cert: fs.readFileSync("security/server-portal-crt.pem"),
    ca: fs.readFileSync("security/ca-portal-crt.pem"),
    requestCert: false,
    rejectUnauthorized: false
};

https.createServer(options, app).listen(3000);