#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc-student.lab kdc-student" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc-research.lab kdc-research" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.research.lab app"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab client"            | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Init KDC database
if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo $PASSWORD | sudo -S kdb5_util create -s -P MasterKeyResearch2026!
fi

# Add Service Principals for App
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! HTTP/app.research.lab@RESEARCH.LAB" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! host/app.research.lab@RESEARCH.LAB" 2>/dev/null || true

# Add Inter-realm Trust Principal: krbtgt/RESEARCH.LAB@STUDENT.LAB with matching shared password and AES-256
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -e aes256-cts-hmac-sha1-96:normal -pw CrossRealmSecret2026! krbtgt/RESEARCH.LAB@STUDENT.LAB" 2>/dev/null || true

echo $PASSWORD | sudo -S service krb5-kdc restart || echo $PASSWORD | sudo -S /usr/sbin/krb5kdc
echo $PASSWORD | sudo -S service krb5-admin-server restart || true
echo "[KDC-RESEARCH] Destination Realm RESEARCH.LAB initialized with Cross-Realm Trust."
