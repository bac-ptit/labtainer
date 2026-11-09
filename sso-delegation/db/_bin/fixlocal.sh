#!/bin/bash
# fixlocal.sh for Backend Database Server
PASSWORD=$1
USER=$2

# Ensure hosts mapping
echo "172.25.0.10 kdc.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 db.lab.lan"  | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Generate database keytab
echo $PASSWORD | sudo -S ktutil <<EOF
add_entry -password -p database/db.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
DbKey2026!
add_entry -password -p host/db.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
SshDbKey2026!
wkt /etc/krb5.keytab
quit
EOF

echo $PASSWORD | sudo -S chmod 644 /etc/krb5.keytab

# Setup users
echo $PASSWORD | sudo -S useradd -ms /bin/bash alice 2>/dev/null || true
echo $PASSWORD | sudo -S useradd -ms /bin/bash admin 2>/dev/null || true

# Setup SSH with GSSAPI
echo $PASSWORD | sudo -S tee -a /etc/ssh/sshd_config <<'EOFSSH'
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
GSSAPIStrictAcceptorCheck no
UsePAM yes
EOFSSH

echo $PASSWORD | sudo -S mkdir -p /run/sshd
echo $PASSWORD | sudo -S service ssh restart 2>/dev/null || true

# Setup lightweight backend API service
cat <<'EOFAPI' > /tmp/db_service.py
import http.server
import socketserver
import json
import urllib.parse

PORT = 8080

class DBHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)
        user = params.get('user', ['anonymous'])[0]
        
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        data = {
            "status": "success",
            "backend": "database.lab.lan",
            "authenticated_as": user,
            "salary": "$5,200" if "alice" in user else "$12,500",
            "record_id": "REC-998124",
            "flag": "SALARY_FLAG_998124"
        }
        self.wfile.write(json.dumps(data, indent=2).encode())

with socketserver.TCPServer(("", PORT), DBHandler) as httpd:
    httpd.serve_forever()
EOFAPI

python3 /tmp/db_service.py >/dev/null 2>&1 &
