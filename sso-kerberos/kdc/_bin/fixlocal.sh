#!/bin/bash
# fixlocal.sh for KDC
PASSWORD=$1
USER=$2

echo $PASSWORD | sudo -S service krb5-kdc stop >/dev/null 2>&1
echo $PASSWORD | sudo -S service krb5-admin-server stop >/dev/null 2>&1

if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo "Initializing Kerberos Realm LAB.LAN..."
    echo $PASSWORD | sudo -S kdb5_util create -r LAB.LAN -s -P MasterPass2026!
    
    # Standard users
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw Password123! alice@LAB.LAN"
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw Password123! bob@LAB.LAN"
    
    # Vulnerable user for AS-REP Roasting (Pre-authentication DISABLED)
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw BackupPass2026! -requires_preauth backup_svc@LAB.LAN"
    
    # Vulnerable service account for Kerberoasting (Weak password + RC4)
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw Summer2026! -e rc4-hmac:normal MSSQLSvc/db.lab.lan:1433@LAB.LAN"
    
    # SPN for Web SSO
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw WebKey2026! HTTP/web.lab.lan@LAB.LAN"
    
    # SPN for SSH SSO
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw SshKey2026! host/ssh.lab.lan@LAB.LAN"
fi

echo $PASSWORD | sudo -S service krb5-kdc restart
echo $PASSWORD | sudo -S service krb5-admin-server restart
