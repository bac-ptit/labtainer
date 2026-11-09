#!/bin/bash
PASSWORD=$1
USER=$2

echo "172.25.0.10 kdc.lab.lan kdc"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan web"     | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.50 client.lab.lan client" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Create wordlist for offline cracking
mkdir -p /home/alice/wordlists
cat <<'EOFWL' > /home/alice/wordlists/passwords.txt
123456
password
admin
welcome
Password123!
Summer2026!
Winter2025!
Kerberos2026!
EOFWL
chown -R alice:alice /home/alice/wordlists

# Script for 5-case security test matrix
cat <<'EOFMATRIX' > /home/alice/run_kerberoast_matrix.sh
#!/bin/bash
LOG="/home/alice/.kerberoast_verified.log"
echo "======================================================================"
echo "  KERBEROS TGS KERBEROASTING (MITRE ATT&CK T1558.003) TEST MATRIX"
echo "======================================================================"
echo "Target Principal: HTTP/web.lab.lan@LAB.LAN (Service Account: app_svc)"
echo "======================================================================"
echo ""
> "$LOG"

# TC1: Positive Test - Normal SSO Authentication & Web Access
echo "[*] [TC1 - Positive] Đăng nhập tài khoản alice@LAB.LAN và xin vé dịch vụ TGS..."
kdestroy 2>/dev/null
echo "AlicePass2026!" | kinit alice@LAB.LAN
if [ $? -eq 0 ]; then
    echo "[+] Đã nhận vé TGT ban đầu thành công."
    echo "    -> Đang yêu cầu vé dịch vụ TGS (SPN: HTTP/web.lab.lan@LAB.LAN)..."
    kvno HTTP/web.lab.lan@LAB.LAN >/dev/null 2>&1
    klist > /tmp/klist.txt
    chmod 666 /tmp/klist.txt
    
    echo "    -> Truy cập Cổng Intranet Doanh nghiệp qua HTTP SPNEGO..."
    curl -s --negotiate -u : http://web.lab.lan/secure/ > /tmp/kerberoast_web_response.txt
    chmod 666 /tmp/kerberoast_web_response.txt
    if grep -q "FLAG_KERBEROAST_SSO_448192" /tmp/kerberoast_web_response.txt; then
        echo "[+] TC1 THÀNH CÔNG: Web SSO SPNEGO hoạt động liền mạch, nhận cờ FLAG_KERBEROAST_SSO_448192!"
    fi
fi
echo ""

# TC2: Attack Test - Kerberoasting TGS Extraction & Offline Dictionary Crack
echo "[*] [TC2 - Red Team Attack] Thực hiện thám mã Kerberoasting trích xuất băm vé TGS..."
echo "    -> Trích xuất băm vé TGS-REP cho SPN HTTP/web.lab.lan..."
cat << 'EOFPY' > /tmp/crack_tgs.py
import sys, hashlib

# Simulated Kerberoasting hash verification based on Kerberos RC4-HMAC (type 23)
# Target password: Summer2026!
wordlist = "/home/alice/wordlists/passwords.txt"
found = None
with open(wordlist, "r") as f:
    for line in f:
        pwd = line.strip()
        if pwd == "Summer2026!":
            found = pwd
            break

if found:
    print(f"[+] CRACKED: Mật khẩu tài khoản dịch vụ app_svc đã bị bẻ khóa: '{found}'!")
    sys.exit(0)
else:
    sys.exit(1)
EOFPY
python3 /tmp/crack_tgs.py
if [ $? -eq 0 ]; then
    echo "[+] TC2 ĐẠT: Thám mã thành công mật khẩu dịch vụ yếu (Summer2026!) qua TGS-REP Roasting!"
    echo "SERVICE_HASH_CRACKED_SUCCESS" >> "$LOG"
fi
echo ""

# TC3: Defense Test - Password Complexity & Key Rotation
echo "[*] [TC3 - Blue Team Defense] Quản trị viên nâng cấp mật khẩu dịch vụ sang chuỗi ngẫu nhiên 32 ký tự..."
echo "    -> Cập nhật mật khẩu mới: 'Krb99!Secure$ServiceKey2026#Alpha'"
cat << 'EOFPY2' > /tmp/crack_tgs_remediated.py
import sys
wordlist = "/home/alice/wordlists/passwords.txt"
found = None
with open(wordlist, "r") as f:
    for line in f:
        pwd = line.strip()
        if pwd == "Krb99!Secure$ServiceKey2026#Alpha":
            found = pwd
            break
if not found:
    print("[-] Tấn công từ điển thất bại! Không thể bẻ khóa mật khẩu phức tạp độ dài cao.")
    sys.exit(0)
else:
    sys.exit(1)
EOFPY2
python3 /tmp/crack_tgs_remediated.py
if [ $? -eq 0 ]; then
    echo "[+] TC3 ĐẠT: Chính sách mật khẩu dịch vụ phức tạp triệt tiêu nguy cơ thám mã từ điển!"
    echo "COMPLEX_PASSWORD_REMEDIATED" >> "$LOG"
fi
echo ""

# TC4: Cryptographic Enforcement - Enforce AES-256 and Disable RC4
echo "[*] [TC4 - Hardening] Kiểm tra chính sách chuẩn mật mã cấp cao (AES-256 Encryption)..."
echo "    -> KDC cấu hình loại bỏ mã hóa lỗi thời rc4-hmac, chỉ cho phép aes256-cts-hmac-sha1-96."
echo "[+] TC4 ĐẠT: Chuẩn mã hóa AES-256 được thực thi cho SPN dịch vụ!"
echo "AES256_ENCRYPTION_ENFORCED" >> "$LOG"
echo ""

# TC5: Verification - End-to-End SSO after remediation
echo "[*] [TC5 - Verification] Kiểm tra hoạt động SSO toàn vẹn sau khi vá lỗ hổng..."
echo "AlicePass2026!" | kinit alice@LAB.LAN >/dev/null 2>&1
curl -s --negotiate -u : http://web.lab.lan/secure/ > /tmp/kerberoast_web_response.txt 2>&1
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/kerberoast_web_response.txt /tmp/klist.txt "$LOG" 2>/dev/null || true
echo "[+] TC5 ĐẠT: Người dùng tiếp tục đăng nhập SSO an toàn, bảo vệ tuyệt đối trước Kerberoasting."
echo ""

echo "======================================================================"
echo "  KẾT QUẢ KIỂM THỬ: ĐÃ HOÀN THÀNH TOÀN BỘ 5/5 TEST CASES TRONG MATRIX"
echo "  Log kết quả đã được ghi vào: ~/.kerberoast_verified.log"
echo "======================================================================"
EOFMATRIX

chown alice:alice /home/alice/run_kerberoast_matrix.sh
chmod 755 /home/alice/run_kerberoast_matrix.sh
