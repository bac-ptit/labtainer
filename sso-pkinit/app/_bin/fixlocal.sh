#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 ca.lab.lan ca" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc.lab.lan kdc" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.lab.lan app" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Generate keytab for HTTP/app.lab.lan and host/app.lab.lan
echo $PASSWORD | sudo -S ktutil <<'EOFKT'
add_entry -password -p HTTP/app.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
AppKey2026!
add_entry -password -p HTTP/app.lab.lan@LAB.LAN -k 1 -e aes128-cts-hmac-sha1-96
AppKey2026!
add_entry -password -p HTTP/app.lab.lan@LAB.LAN -k 1 -e rc4-hmac
AppKey2026!
add_entry -password -p host/app.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
AppKey2026!
wkt /etc/apache2/http.keytab
quit
EOFKT

echo $PASSWORD | sudo -S ln -sf /etc/apache2/http.keytab /etc/krb5.keytab
echo $PASSWORD | sudo -S chown root:www-data /etc/apache2/http.keytab
echo $PASSWORD | sudo -S chmod 644 /etc/apache2/http.keytab

# Configure Apache VirtualHost
echo $PASSWORD | sudo -S tee /etc/apache2/sites-available/pkinit-app.conf <<'EOFCONF'
<VirtualHost *:80>
    ServerName app.lab.lan
    DocumentRoot /var/www/html

    <Directory "/var/www/html/secure">
        AuthType GSSAPI
        AuthName "Enterprise PKINIT SSO Intranet"
        GssapiCredStore keytab:/etc/apache2/http.keytab
        GssapiBasicAuth Off
        GssapiLocalName On
        Require valid-user
    </Directory>
</VirtualHost>
EOFCONF

echo $PASSWORD | sudo -S a2ensite pkinit-app.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S a2dissite 000-default.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S service apache2 restart

# Ensure user alice exists for SSH SSO
echo $PASSWORD | sudo -S useradd -m -s /bin/bash alice 2>/dev/null || true
echo "alice:Password123!" | echo $PASSWORD | sudo -S chpasswd

# Configure SSH GSSAPI
echo $PASSWORD | sudo -S tee -a /etc/ssh/sshd_config <<'EOFSSH'
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
EOFSSH
echo $PASSWORD | sudo -S service ssh restart

echo "[APP] Apache SPNEGO and SSH SSO running."
