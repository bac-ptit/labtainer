#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 app.lab.lan app"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 workstation.lab.lan workstation client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo $PASSWORD | sudo -S kdb5_util create -s -P MasterKey2026!
fi

# Add Users and Services
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AlicePass2026! alice@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! HTTP/app.lab.lan@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! host/app.lab.lan@LAB.LAN" 2>/dev/null || true

echo $PASSWORD | sudo -S service krb5-kdc restart || echo $PASSWORD | sudo -S /usr/sbin/krb5kdc
echo $PASSWORD | sudo -S service krb5-admin-server restart || true
echo "[KDC] Kerberos KDC initialized for Pass-the-Ticket lab."
