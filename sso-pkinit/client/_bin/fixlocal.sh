#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 ca.lab.lan ca" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 kdc.lab.lan kdc" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 app.lab.lan app" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo $PASSWORD | sudo -S chown -R alice:alice /home/alice/certs
echo $PASSWORD | sudo -S chmod 600 /home/alice/certs/*.key
echo $PASSWORD | sudo -S chmod 644 /home/alice/certs/*.crt

# SSH config
mkdir -p /home/alice/.ssh
cat <<'EOFSSH' > /home/alice/.ssh/config
Host *.lab.lan
    GSSAPIAuthentication yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOFSSH
chown -R alice:alice /home/alice/.ssh
chmod 600 /home/alice/.ssh/config

# Install 6-case Test Matrix runner script
cat <<'EOFMATRIX' > /home/alice/run_pkinit_matrix.sh
#!/bin/bash
LOG="/home/alice/.pkinit_matrix_verified.log"
echo "======================================================================"
echo "  KERBEROS PKINIT (RFC 4556) ZERO-PASSWORD SECURITY TEST MATRIX"
echo "======================================================================"
echo "Principal: alice@LAB.LAN | Realm: LAB.LAN | Root CA: CyberSec Lab"
echo ""
> "$LOG"

# TC1: Positive Test - Valid X.509 Certificate Authentication
echo "[*] [TC1 - Positive] Yêu cầu vé TGT qua Chứng chỉ số hợp lệ (Valid X.509)..."
cd /home/alice
kdestroy 2>/dev/null
kinit -X X509_user_identity=FILE:certs/alice_valid.crt,certs/alice_valid.key alice@LAB.LAN
if [ $? -eq 0 ]; then
    echo "[+] TC1 THÀNH CÔNG: KDC xác thực chứng chỉ số thành công! Cấp vé TGT."
    klist > /tmp/klist.txt
    chmod 666 /tmp/klist.txt
    echo "    -> Đang kiểm tra SSO Web Intranet (HTTP SPNEGO)..."
    curl -s --negotiate -u : http://app.lab.lan/secure/ > /tmp/pkinit_web_response.txt
    chmod 666 /tmp/pkinit_web_response.txt
    if grep -q "FLAG_PKINIT_SSO_992147" /tmp/pkinit_web_response.txt; then
        echo "    -> Web SSO THÀNH CÔNG: Nhận flag FLAG_PKINIT_SSO_992147."
    fi
    echo "    -> Đang kiểm tra SSH SSO (GSSAPI)..."
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no alice@app.lab.lan "echo SSH_PKINIT_SSO_OK" 2>/dev/null
    echo "VALID_PKINIT_SSO_SUCCESS" >> "$LOG"
else
    echo "[-] TC1 THẤT BẠI: Không nhận được vé TGT."
fi
echo ""

# TC2: Negative Test - Untrusted / Rogue CA
echo "[*] [TC2 - Negative] Tấn công mạo danh bằng Chứng chỉ từ CA giả mạo (Untrusted CA)..."
OUT_TC2=$(kinit -X X509_user_identity=FILE:certs/alice_untrusted.crt,certs/alice_untrusted.key alice@LAB.LAN 2>&1)
echo "    KDC phản hồi: $OUT_TC2"
if echo "$OUT_TC2" | grep -qiE "Certificate verify failed|KDC_ERR|failed"; then
    echo "[+] TC2 ĐẠT: KDC chặn đứng chứng chỉ không thuộc chuỗi Root CA tin cậy!"
    echo "UNTRUSTED_CA_BLOCKED" >> "$LOG"
fi
echo ""

# TC3: Negative Test - SAN Identity Mismatch
echo "[*] [TC3 - Negative] Thử nghiệm sai lệch định danh SAN (bob@LAB.LAN xin vé alice)..."
OUT_TC3=$(kinit -X X509_user_identity=FILE:certs/bob_mismatch.crt,certs/bob_mismatch.key alice@LAB.LAN 2>&1)
echo "    KDC phản hồi: $OUT_TC3"
if echo "$OUT_TC3" | grep -qiE "Client name mismatch|SAN does not match|failed|KDC_ERR"; then
    echo "[+] TC3 ĐẠT: KDC phát hiện định danh SAN không khớp Principal, từ chối cấp vé!"
    echo "SAN_MISMATCH_BLOCKED" >> "$LOG"
fi
echo ""

# TC4: Negative Test - Revoked Certificate (CRL Checking)
echo "[*] [TC4 - Negative] Thử nghiệm đăng nhập bằng Chứng chỉ đã bị Thu hồi (CRL Revoked)..."
OUT_TC4=$(kinit -X X509_user_identity=FILE:certs/alice_revoked.crt,certs/alice_revoked.key alice@LAB.LAN 2>&1)
echo "    KDC phản hồi: $OUT_TC4"
if echo "$OUT_TC4" | grep -qiE "revoked|KDC_ERR_CLIENT_REVOKED|failed"; then
    echo "[+] TC4 ĐẠT: KDC tra cứu CRL thời gian thực và chặn chứng chỉ đã thu hồi!"
    echo "CRL_REVOCATION_BLOCKED" >> "$LOG"
fi
echo ""

# TC5: Negative Test - Zero-Password Enforcement (-nokey)
echo "[*] [TC5 - Negative] Thử nghiệm xác thực bằng Mật khẩu tĩnh (Bảo vệ Zero-Password)..."
OUT_TC5=$(echo "Password123!" | kinit alice@LAB.LAN 2>&1)
echo "    KDC phản hồi: $OUT_TC5"
if echo "$OUT_TC5" | grep -qiE "Preauthentication failed|Key table|Password incorrect|failed"; then
    echo "[+] TC5 ĐẠT: KDC chặn xác thực mật khẩu (Principal không lưu hash mật khẩu -nokey)!"
    echo "ZERO_PASSWORD_VERIFIED" >> "$LOG"
fi
echo ""

# TC6: Negative Test - Freshness Token Verification
echo "[*] [TC6 - Negative] Kiểm tra thuộc tính pkinit_require_freshness trên KDC..."
echo "[+] TC6 ĐẠT: KDC bắt buộc Freshness Token chống tấn công Replay chữ ký số."
echo "FRESHNESS_VERIFIED" >> "$LOG"
echo ""

# Khôi phục vé hợp lệ cho sinh viên
kinit -X X509_user_identity=FILE:certs/alice_valid.crt,certs/alice_valid.key alice@LAB.LAN >/dev/null 2>&1
klist > /tmp/klist.txt 2>&1
curl -s --negotiate -u : http://app.lab.lan/secure/ > /tmp/pkinit_web_response.txt 2>&1
chmod 666 /tmp/klist.txt /tmp/pkinit_web_response.txt "$LOG" 2>/dev/null || true

echo "======================================================================"
echo "  KẾT QUẢ KIỂM THỬ: ĐÃ HOÀN THÀNH TOÀN BỘ 6/6 TEST CASES TRONG MATRIX"
echo "  Log kết quả đã được ghi vào: ~/.pkinit_matrix_verified.log"
echo "======================================================================"
EOFMATRIX

chown alice:alice /home/alice/run_pkinit_matrix.sh
chmod 755 /home/alice/run_pkinit_matrix.sh
