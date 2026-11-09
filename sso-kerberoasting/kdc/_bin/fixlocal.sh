#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan web"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo $PASSWORD | sudo -S kdb5_util create -s -P MasterKey2026!
fi

# Add Client Principal (Alice)
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AlicePass2026! alice@LAB.LAN" 2>/dev/null || true

# Add Service Principal with WEAK password (Summer2026!) and RC4-HMAC supported
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw Summer2026! HTTP/web.lab.lan@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw Summer2026! app_svc@LAB.LAN" 2>/dev/null || true

echo $PASSWORD | sudo -S service krb5-kdc restart || echo $PASSWORD | sudo -S /usr/sbin/krb5kdc
echo $PASSWORD | sudo -S service krb5-admin-server restart || true
echo "[KDC] Kerberos KDC initialized for Kerberoasting lab."
