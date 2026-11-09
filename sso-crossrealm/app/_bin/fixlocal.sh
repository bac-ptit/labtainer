#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc-student.lab kdc-student" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc-research.lab kdc-research" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.research.lab app"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab client"            | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Generate Apache keytab for HTTP and host
echo $PASSWORD | sudo -S ktutil <<'EOFKT'
add_entry -password -p HTTP/app.research.lab@RESEARCH.LAB -k 1 -e aes256-cts-hmac-sha1-96
AppKey2026!
add_entry -password -p host/app.research.lab@RESEARCH.LAB -k 1 -e aes256-cts-hmac-sha1-96
AppKey2026!
wkt /etc/apache2/http.keytab
quit
EOFKT

echo $PASSWORD | sudo -S ln -sf /etc/apache2/http.keytab /etc/krb5.keytab
echo $PASSWORD | sudo -S chown root:www-data /etc/apache2/http.keytab
echo $PASSWORD | sudo -S chmod 644 /etc/apache2/http.keytab

# Configure Apache VirtualHost
echo $PASSWORD | sudo -S tee /etc/apache2/sites-available/crossrealm-app.conf <<'EOFCONF'
<VirtualHost *:80>
    ServerName app.research.lab
    DocumentRoot /var/www/html

    <Directory "/var/www/html/portal">
        AuthType GSSAPI
        AuthName "Federated Research Institute Portal"
        GssapiCredStore keytab:/etc/apache2/http.keytab
        GssapiBasicAuth Off
        GssapiLocalName Off
        Require valid-user
    </Directory>
</VirtualHost>
EOFCONF

echo $PASSWORD | sudo -S a2ensite crossrealm-app.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S a2dissite 000-default.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S service apache2 restart

# Create researcher local user account with strict .k5login authorization
echo $PASSWORD | sudo -S useradd -m -s /bin/bash researcher 2>/dev/null || true
echo "researcher:ResearchPass123!" | echo $PASSWORD | sudo -S chpasswd

# .k5login ONLY authorizes alice@STUDENT.LAB (charlie is unauthorized!)
echo "alice@STUDENT.LAB" | echo $PASSWORD | sudo -S tee /home/researcher/.k5login >/dev/null
echo $PASSWORD | sudo -S chown researcher:researcher /home/researcher/.k5login
echo $PASSWORD | sudo -S chmod 600 /home/researcher/.k5login

# Configure OpenSSH
echo $PASSWORD | sudo -S tee -a /etc/ssh/sshd_config <<'EOFSSH'
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
GSSAPIStrictAcceptorCheck no
EOFSSH
echo $PASSWORD | sudo -S service ssh restart

echo "[APP] Research Portal HTTP SPNEGO and SSH SSO running with .k5login authorization."
