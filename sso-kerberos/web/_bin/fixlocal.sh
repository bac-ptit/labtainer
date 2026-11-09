#!/bin/bash
# fixlocal.sh for Web Server
PASSWORD=$1
USER=$2

# Generate Apache keytab with matching key and principal
echo $PASSWORD | sudo -S ktutil <<EOF
add_entry -password -p HTTP/web.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
WebKey2026!
add_entry -password -p HTTP/web.lab.lan@LAB.LAN -k 1 -e aes128-cts-hmac-sha1-96
WebKey2026!
add_entry -password -p HTTP/web.lab.lan@LAB.LAN -k 1 -e rc4-hmac
WebKey2026!
wkt /etc/apache2/http.keytab
quit
EOF

# Ensure keytab is readable by Apache and linked as default keytab
echo $PASSWORD | sudo -S ln -sf /etc/apache2/http.keytab /etc/krb5.keytab
echo $PASSWORD | sudo -S chown root:www-data /etc/apache2/http.keytab
echo $PASSWORD | sudo -S chmod 644 /etc/apache2/http.keytab

# Enable Apache site and modules
echo $PASSWORD | sudo -S a2enmod auth_gssapi headers
echo $PASSWORD | sudo -S a2dissite 000-default.conf >/dev/null 2>&1
echo $PASSWORD | sudo -S a2ensite intranet.conf
echo $PASSWORD | sudo -S service apache2 restart
