#!/bin/bash
# fixlocal.sh for SSH Server
PASSWORD=$1
USER=$2

# Ensure privilege separation directory exists for OpenSSH
echo $PASSWORD | sudo -S mkdir -p /run/sshd /var/run/sshd
echo $PASSWORD | sudo -S chmod 0755 /run/sshd /var/run/sshd
echo "d /run/sshd 0755 root root" | echo $PASSWORD | sudo -S tee /etc/tmpfiles.d/sshd.conf >/dev/null

# Create host keytab using ktutil
echo $PASSWORD | sudo -S ktutil <<EOF
add_entry -password -p host/ssh.lab.lan@LAB.LAN -k 1 -e aes256-cts-hmac-sha1-96
SshKey2026!
add_entry -password -p host/ssh.lab.lan@LAB.LAN -k 1 -e aes128-cts-hmac-sha1-96
SshKey2026!
add_entry -password -p host/ssh.lab.lan@LAB.LAN -k 1 -e rc4-hmac
SshKey2026!
wkt /etc/krb5.keytab
quit
EOF

echo $PASSWORD | sudo -S chmod 644 /etc/krb5.keytab

# Configure sshd to accept any keytab principal
echo $PASSWORD | sudo -S sed -i 's/GSSAPIStrictAcceptorCheck yes/GSSAPIStrictAcceptorCheck no/' /etc/ssh/sshd_config 2>/dev/null

# Ensure user alice exists with Password123!
id alice >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo $PASSWORD | sudo -S useradd -ms /bin/bash alice
    echo "alice:Password123!" | echo $PASSWORD | sudo -S chpasswd
fi

# Secret data file for student evaluation
echo "SECRET_SSH_KEY" | echo $PASSWORD | sudo -S tee /home/alice/confidential_project.txt >/dev/null
echo $PASSWORD | sudo -S chown alice:alice /home/alice/confidential_project.txt

# Ensure SSH service is running
echo $PASSWORD | sudo -S /usr/sbin/sshd -t
echo $PASSWORD | sudo -S service ssh restart 2>/dev/null || echo $PASSWORD | sudo -S service xinetd restart
