#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 ca.lab.lan ca" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc.lab.lan kdc" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.lab.lan app" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo $PASSWORD | sudo -S chmod 600 /var/lib/krb5kdc/kdc.key
echo $PASSWORD | sudo -S chmod 644 /var/lib/krb5kdc/kdc.crt /var/lib/krb5/ca_root.crt /var/lib/krb5/kdc_crl.pem

# Create Kerberos Database if missing
if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo $PASSWORD | sudo -S kdb5_util create -s -P MasterKey2026!
fi

# Add Service Principals for App
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! HTTP/app.lab.lan@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal -pw AppKey2026! host/app.lab.lan@LAB.LAN" 2>/dev/null || true

# Add Client Principals with ZERO-PASSWORD flag (+requires_preauth -nokey)
echo $PASSWORD | sudo -S kadmin.local -q "add_principal +requires_preauth -nokey alice@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal +requires_preauth -nokey bob@LAB.LAN" 2>/dev/null || true
echo $PASSWORD | sudo -S kadmin.local -q "add_principal +requires_preauth -nokey alice_revoked@LAB.LAN" 2>/dev/null || true

# Restart KDC
echo $PASSWORD | sudo -S service krb5-kdc restart || echo $PASSWORD | sudo -S /usr/sbin/krb5kdc
echo $PASSWORD | sudo -S service krb5-admin-server restart || true
echo "[KDC] MIT Kerberos KDC running with PKINIT enabled."
