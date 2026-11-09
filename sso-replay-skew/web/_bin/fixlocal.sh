#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan web"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo $PASSWORD | sudo -S ktutil <<'EOFKT'
add_entry -password -p HTTP/web.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
AppKey2026!
wkt /etc/apache2/http.keytab
quit
EOFKT

echo $PASSWORD | sudo -S ln -sf /etc/apache2/http.keytab /etc/krb5.keytab
echo $PASSWORD | sudo -S chown root:www-data /etc/apache2/http.keytab
echo $PASSWORD | sudo -S chmod 644 /etc/apache2/http.keytab

# Configure Apache
echo $PASSWORD | sudo -S tee /etc/apache2/sites-available/replayskew-app.conf <<'EOFCONF'
<VirtualHost *:80>
    ServerName web.lab.lan
    DocumentRoot /var/www/html

    <Directory "/var/www/html/portal">
        AuthType GSSAPI
        AuthName "Time-Synchronized SPNEGO Portal"
        GssapiCredStore keytab:/etc/apache2/http.keytab
        GssapiBasicAuth Off
        GssapiLocalName On
        Require valid-user
    </Directory>
</VirtualHost>
EOFCONF

echo $PASSWORD | sudo -S a2ensite replayskew-app.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S a2dissite 000-default.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S service apache2 restart

echo "[WEB] Apache HTTP SPNEGO running."
