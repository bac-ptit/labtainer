#!/bin/bash
# fixlocal.sh for KDC
PASSWORD=$1
USER=$2

echo $PASSWORD | sudo -S service krb5-kdc stop >/dev/null 2>&1
echo $PASSWORD | sudo -S service krb5-admin-server stop >/dev/null 2>&1

if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo "Initializing Kerberos Realm LAB.LAN for Multi-tier Delegation..."
    echo $PASSWORD | sudo -S kdb5_util create -r LAB.LAN -s -P MasterPass2026!
    
    # Standard users
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw Password123! alice@LAB.LAN"
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw Password123! bob@LAB.LAN"
    
    # Domain Administrator
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw MasterAdminPass2026! admin@LAB.LAN"
    
    # Service Principals
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw WebKey2026! HTTP/web.lab.lan@LAB.LAN"
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw DbKey2026! database/db.lab.lan@LAB.LAN"
    echo $PASSWORD | sudo -S kadmin.local -q "addprinc -pw SshDbKey2026! host/db.lab.lan@LAB.LAN"
fi

echo $PASSWORD | sudo -S service krb5-kdc restart
echo $PASSWORD | sudo -S service krb5-admin-server restart
