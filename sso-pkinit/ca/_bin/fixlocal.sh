#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 ca.lab.lan ca" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc.lab.lan kdc" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.lab.lan app" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo "[CA] OpenSSL Enterprise CA Initialized."
