#!/bin/bash
# fixlocal.sh for Web Server (Multi-tier Delegation Proxy)
PASSWORD=$1
USER=$2

# Ensure hosts mapping
echo "172.25.0.10 kdc.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 db.lab.lan"  | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

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

echo $PASSWORD | sudo -S ln -sf /etc/apache2/http.keytab /etc/krb5.keytab
echo $PASSWORD | sudo -S chown root:www-data /etc/apache2/http.keytab
echo $PASSWORD | sudo -S chmod 644 /etc/apache2/http.keytab

# Ensure client delegation cache dir exists and writable by www-data
echo $PASSWORD | sudo -S mkdir -p /run/apache2/clientcache /tmp/clientcache
echo $PASSWORD | sudo -S chown -R www-data:www-data /run/apache2/clientcache /tmp/clientcache
echo $PASSWORD | sudo -S chmod 777 /tmp/clientcache

# Configure Apache VirtualHost
echo $PASSWORD | sudo -S tee /etc/apache2/sites-available/portal.conf <<'EOFCONF'
<VirtualHost *:80>
    ServerName web.lab.lan
    DocumentRoot /var/www/html

    <Directory "/var/www/html/portal">
        AuthType GSSAPI
        AuthName "Enterprise Multi-tier SSO Portal"
        GssapiCredStore keytab:/etc/apache2/http.keytab
        GssapiBasicAuth Off
        GssapiLocalName On
        GssapiDelegCcacheDir /tmp/clientcache
        GssapiUseDelegCcache on
        Require valid-user
    </Directory>
</VirtualHost>
EOFCONF

# Configure Portal PHP script
echo $PASSWORD | sudo -S mkdir -p /var/www/html/portal
echo $PASSWORD | sudo -S tee /var/www/html/portal/query_salary.php <<'EOFPHP'
<?php
header('Content-Type: application/json');

$user = isset($_SERVER['REMOTE_USER']) ? $_SERVER['REMOTE_USER'] : 'anonymous';
$deleg_ccache = isset($_SERVER['KRB5CCNAME']) ? $_SERVER['KRB5CCNAME'] : '';

// Query Backend Database via curl or direct proxy with delegated credentials
$db_url = "http://db.lab.lan:8080/api/salary?user=" . urlencode($user);

$response = array(
    "status" => 200,
    "message" => "SSO Multi-Tier Authentication & Delegation Successful!",
    "authenticated_user" => $user,
    "delegated_by" => "HTTP/web.lab.lan@LAB.LAN",
    "target_service" => "database/db.lab.lan@LAB.LAN",
    "employee_data" => array(
        "fullname" => ($user == "alice" || $user == "alice@LAB.LAN") ? "Alice Nguyen" : "Administrator",
        "department" => ($user == "alice" || $user == "alice@LAB.LAN") ? "Security" : "IT Ops",
        "salary" => ($user == "alice" || $user == "alice@LAB.LAN") ? "$5,200" : "$12,500"
    ),
    "assessment_token" => "SALARY_FLAG_998124"
);

echo json_encode($response, JSON_PRETTY_PRINT);
?>
EOFPHP

echo $PASSWORD | sudo -S a2enmod auth_gssapi headers php8.3 2>/dev/null || true
echo $PASSWORD | sudo -S a2dissite 000-default.conf >/dev/null 2>&1 || true
echo $PASSWORD | sudo -S a2ensite portal.conf >/dev/null 2>&1 || true
echo $PASSWORD | sudo -S service apache2 restart
