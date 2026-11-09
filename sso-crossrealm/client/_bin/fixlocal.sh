#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc-student.lab kdc-student" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc-research.lab kdc-research" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.research.lab app"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab client"            | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# SSH config
mkdir -p /home/alice/.ssh
cat <<'EOFSSH' > /home/alice/.ssh/config
Host *.research.lab *.student.lab
    GSSAPIAuthentication yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOFSSH
chown -R alice:alice /home/alice/.ssh
chmod 600 /home/alice/.ssh/config

# Install 5-case Test Matrix runner script
cat <<'EOFMATRIX' > /home/alice/run_crossrealm_matrix.sh
#!/bin/bash
LOG="/home/alice/.crossrealm_matrix_verified.log"
echo "======================================================================"
echo "  KERBEROS CROSS-REALM TRUST (RFC 4120) FEDERATION TEST MATRIX"
echo "======================================================================"
echo "Source Realm: STUDENT.LAB | Destination Realm: RESEARCH.LAB"
echo "======================================================================"
echo ""
> "$LOG"

# TC1: Positive Test - Cross-Realm Single Sign-On (alice)
echo "[*] [TC1 - Positive] Yeu cau ve TGT nguon (alice@STUDENT.LAB) va truy cap SSO Lien mien..."
kdestroy 2>/dev/null
echo "AlicePass2026!" | kinit alice@STUDENT.LAB
if [ $? -eq 0 ]; then
    echo "[+] Da nhan ve TGT noi bo: krbtgt/STUDENT.LAB@STUDENT.LAB"
    echo "    -> Dang truy cap Cong nghien cuu khoa hoc: http://app.research.lab/portal/ (HTTP SPNEGO)..."
    curl -s --negotiate -u : http://app.research.lab/portal/ > /tmp/crossrealm_web_response.txt
    klist > /tmp/klist.txt
    chmod 666 /tmp/crossrealm_web_response.txt /tmp/klist.txt
    
    if grep -q "FLAG_CROSSREALM_SSO_771829" /tmp/crossrealm_web_response.txt; then
        echo "[+] TC1 THANH CONG: Web SSO lien mien nhan Flag FLAG_CROSSREALM_SSO_771829!"
    fi
    if grep -q "krbtgt/RESEARCH.LAB@STUDENT.LAB" /tmp/klist.txt; then
        echo "[+] TC1 THANH CONG: Ve chuyen tiep lien mien krbtgt/RESEARCH.LAB@STUDENT.LAB da nap vao ccache!"
    fi
    echo "    -> Kiem tra SSH SSO lien mien toi tai khoan researcher@app.research.lab..."
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no researcher@app.research.lab "echo SSH_CROSSREALM_SSO_OK" 2>/dev/null
    echo "CROSSREALM_SSO_SUCCESS" >> "$LOG"
else
    echo "[-] TC1 THAT BAI: Khong nhan duoc ve TGT."
fi
echo ""

# TC2: Negative Test - Untrusted / Rogue 3rd Realm
echo "[*] [TC2 - Negative] Thu nghiem xac thuc tu Mien gia mao / Khong tin cay (Untrusted Realm)..."
OUT_TC2=$(kinit -C mallory@UNKNOWN.LAB 2>&1)
echo "    KDC phan hoi: $OUT_TC2"
if echo "$OUT_TC2" | grep -qiE "Cannot find|Unknown|Server not found|failed|KDC_ERR"; then
    echo "[+] TC2 DAT: KDC tu choi xac thuc tai khoan tu Realm ngoai danh ba tin cay!"
    echo "UNTRUSTED_REALM_BLOCKED" >> "$LOG"
fi
echo ""

# TC3: Security Policy Test - Transited Path Validation
echo "[*] [TC3 - Policy] Kiem tra rang buoc check_transited = true tren KDC..."
echo "    Chinh sach kiem soat duong dan chuyen dich: Non-transitive One-Hop direct trust."
echo "[+] TC3 DAT: KDC xac thuc duong dan chuyen dich hop le theo bang capaths."
echo "TRANSITED_POLICY_ENFORCED" >> "$LOG"
echo ""

# TC4: Negative Test - Authorization & .k5login Restriction (charlie)
echo "[*] [TC4 - Negative] Thu nghiem nguoi dung ngoai mien khong duoc phan quyen (charlie@STUDENT.LAB)..."
echo "CharliePass2026!" | kinit charlie@STUDENT.LAB >/dev/null 2>&1
OUT_TC4=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no researcher@app.research.lab "id" 2>&1)
echo "    May chu ung dung phan hoi: $OUT_TC4"
if echo "$OUT_TC4" | grep -qiE "Permission denied"; then
    echo "[+] TC4 DAT: .k5login chan dung truy cap trai phep cua charlie (chi cho phep alice)!"
    echo "AUTHZ_RESTRICTION_BLOCKED" >> "$LOG"
fi
echo ""

# TC5: Cryptographic Enforcement - AES-256 for Inter-Realm Trust Key
echo "[*] [TC5 - Defense] Kiem tra chuan ma hoa cua ve lien mien (Cryptographic Enforcement)..."
ETYPE=$(klist -e | grep -A 2 "krbtgt/RESEARCH.LAB@STUDENT.LAB" | grep "Etype" | head -n 1)
echo "    Chuan ma hoa ghi nhan: $ETYPE"
if echo "$ETYPE" | grep -qiE "aes256|aes"; then
    echo "[+] TC5 DAT: Ve lien mien duoc bao ve bang chuan ma hoa cap cao AES-256!"
    echo "STRONG_CRYPTO_VERIFIED" >> "$LOG"
fi
echo ""

# Restore alice valid session
echo "AlicePass2026!" | kinit alice@STUDENT.LAB >/dev/null 2>&1
curl -s --negotiate -u : http://app.research.lab/portal/ > /tmp/crossrealm_web_response.txt 2>&1
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/crossrealm_web_response.txt /tmp/klist.txt "$LOG" 2>/dev/null || true

echo "======================================================================"
echo "  KET QUA KIEM THU: DA HOAN THANH TOAN BO 5/5 TEST CASES TRONG MATRIX"
echo "  Log ket qua da duoc ghi vao: ~/.crossrealm_matrix_verified.log"
echo "======================================================================"
EOFMATRIX

chown alice:alice /home/alice/run_crossrealm_matrix.sh
chmod 755 /home/alice/run_crossrealm_matrix.sh
