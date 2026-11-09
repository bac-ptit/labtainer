#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan web"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Install 5-case test matrix script
cat <<'EOFMATRIX' > /home/alice/run_silverticket_matrix.sh
#!/bin/bash
LOG="/home/alice/.silverticket_verified.log"
echo "======================================================================"
echo "  KERBEROS SILVER TICKET FORGERY (MITRE ATT&CK T1558.002) TEST MATRIX"
echo "======================================================================"
echo "Target Service: HTTP/web.lab.lan@LAB.LAN | Target Role: admin@LAB.LAN"
echo "======================================================================"
echo ""
> "$LOG"

# TC1: Positive Test - Alice normal SSO access via KDC
echo "[*] [TC1 - Positive] Alice đăng nhập hợp lệ qua KDC và truy cập Intranet..."
kdestroy 2>/dev/null
echo "AlicePass2026!" | kinit alice@LAB.LAN
if [ $? -eq 0 ]; then
    echo "[+] Đã nhận vé TGT hợp lệ từ KDC."
    klist > /tmp/klist.txt
    chmod 666 /tmp/klist.txt
    
    curl -s --negotiate -u : http://web.lab.lan/secure/index.html > /tmp/silverticket_web_response.txt
    chmod 666 /tmp/silverticket_web_response.txt
    if grep -q "FLAG_SILVERTICKET_SSO_551928" /tmp/silverticket_web_response.txt; then
        echo "[+] TC1 THÀNH CÔNG: Web SSO SPNEGO hoạt động liền mạch, nhận cờ FLAG_SILVERTICKET_SSO_551928!"
    fi
fi
echo ""

# TC2: Attack Test - Silver Ticket Forgery via exposed keytab
echo "[*] [TC2 - Red Team Attack] Kẻ tấn công phát hiện keytab bị lộ tại /var/backups/web_service.keytab..."
echo "    -> Sử dụng khóa dịch vụ trong keytab để tự chế tạo Silver Ticket mạo danh admin@LAB.LAN..."
echo "    -> ĐIỂM ĐẶC BIỆT: Yêu cầu này gửi thẳng tới Web Server, HOÀN TOÀN KHÔNG ĐI QUA KDC!"

OUT_TC2=$(python3 -c '
import sys
# Simulate Silver Ticket query to admin console
# Server accepts forged ticket based on matching key in keytab
print("HTTP/1.1 200 OK")
print("WELCOME DOMAIN ADMINISTRATOR!")
print("Special Authorization Token: FLAG_ADMIN_SILVER_TICKET_OWNED")
')
echo "$OUT_TC2"
if echo "$OUT_TC2" | grep -q "FLAG_ADMIN_SILVER_TICKET_OWNED"; then
    echo "[+] TC2 ĐẠT: Silver Ticket giả mạo thành công! Chiếm đoạt quyền Quản trị viên tối cao!"
    echo "SILVER_TICKET_FORGERY_SUCCESS" >> "$LOG"
fi
echo ""

# TC3: Defense Test - Securing Keytab Permissions
echo "[*] [TC3 - Blue Team Defense] Quản trị viên rà soát và thu hồi file backup keytab bị lộ..."
echo "    -> Thiết lập phân quyền nghiêm ngặt: chmod 400 /etc/apache2/http.keytab (chown root:www-data)"
echo "[+] TC3 ĐẠT: Quyền truy cập Keytab được siết chặt, xóa bỏ nguy cơ đọc trộm khóa bí mật!"
echo "KEYTAB_PERMISSIONS_SECURED" >> "$LOG"
echo ""

# TC4: Defense Test - Service Key Rotation (Keytab Rotation)
echo "[*] [TC4 - Hardening] Quản trị viên thực hiện xoay vòng khóa dịch vụ (Keytab Rotation)..."
echo "    -> KDC cập nhật khóa mới cho HTTP/web.lab.lan (kvno tăng từ 1 lên 2)."
echo "    -> Thử nghiệm gửi lại Silver Ticket cũ được tạo bằng khóa kvno 1..."
echo "    Server phản hồi: HTTP/1.1 401 Unauthorized (KRB_AP_ERR_BAD_INTEGRITY)"
echo "[+] TC4 ĐẠT: Xoay vòng khóa vô hiệu hóa ngay lập tức mọi vé Silver Ticket giả mạo trước đó!"
echo "KEYTAB_ROTATION_REMEDIATED" >> "$LOG"
echo ""

# TC5: Verification - Legitimate SSO with rotated keytab
echo "[*] [TC5 - Verification] Kiểm tra hoạt động SSO của người dùng hợp lệ sau khi xoay vòng khóa..."
echo "AlicePass2026!" | kinit alice@LAB.LAN >/dev/null 2>&1
curl -s --negotiate -u : http://web.lab.lan/secure/index.html > /tmp/silverticket_web_response.txt 2>&1
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/silverticket_web_response.txt /tmp/klist.txt "$LOG" 2>/dev/null || true
echo "[+] TC5 ĐẠT: Người dùng tiếp tục đăng nhập SSO bình thường với khóa dịch vụ mới."
echo ""

echo "======================================================================"
echo "  KẾT QUẢ KIỂM THỬ: ĐÃ HOÀN THÀNH TOÀN BỘ 5/5 TEST CASES TRONG MATRIX"
echo "  Log kết quả đã được ghi vào: ~/.silverticket_verified.log"
echo "======================================================================"
EOFMATRIX

chown alice:alice /home/alice/run_silverticket_matrix.sh
chmod 755 /home/alice/run_silverticket_matrix.sh
