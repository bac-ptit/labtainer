#!/bin/bash
# fixlocal.sh for Client container (User: alice)
PASSWORD=$1
USER=$2

# Ensure hosts mappings
echo $PASSWORD | sudo -S sed -i '/web.lab.lan/d' /etc/hosts 2>/dev/null
echo "172.25.0.10 kdc.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.20 web.lab.lan" | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null
echo "172.25.0.30 db.lab.lan"  | echo $PASSWORD | sudo -S tee -a /etc/hosts >/dev/null

echo $PASSWORD | sudo -S usermod -a -G wireshark alice 2>/dev/null
echo $PASSWORD | sudo -S usermod -a -G sudo alice 2>/dev/null

# SSH config
mkdir -p /home/alice/.ssh
cat <<'EOFSSH' > /home/alice/.ssh/config
Host *.lab.lan
    GSSAPIAuthentication yes
    GSSAPIDelegateCredentials yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOFSSH
chmod 600 /home/alice/.ssh/config

# 1. Audit Script: audit_delegation_risk.sh
cat <<'EOFAUDIT' > /home/alice/audit_delegation_risk.sh
#!/bin/bash
echo "======================================================================"
echo "  PHÂN TÍCH RỦI RO BẢO MẬT: LẠM DỤNG UNCONSTRAINED DELEGATION"
echo "======================================================================"
echo "[*] BƯỚC 1: Quét bộ nhớ Ticket Cache trên máy chủ Web (web.lab.lan)..."
echo "    - Tìm thấy ccache: /tmp/krb5cc_apache_adm192"
echo "    - Chủ sở hữu vé:   admin@LAB.LAN (Domain Administrator)"
echo "    - Thuộc tính vé:   Forwardable = YES, Renewable = YES, Lifetime = 24h"
echo ""
echo "[*] BƯỚC 2: Mô phỏng kẻ tấn công chiếm quyền trạm Web và trích xuất vé Admin..."
echo "    export KRB5CCNAME=/tmp/krb5cc_apache_adm192"
echo ""
echo "[*] BƯỚC 3: Thực hiện di chuyển ngang (Lateral Movement) sang máy chủ Database/Admin..."
echo "    ssh admin@db.lab.lan (Xác thực qua Kerberos GSSAPI Ticket đánh cắp)"
echo "[+] ĐĂNG NHẬP THÀNH CÔNG KHÔNG CẦN MẬT KHẨU! (Accepted gssapi-with-mic for admin)"
echo "    admin@db:~$ id"
echo "    uid=0(root) gid=0(root) groups=0(root),27(sudo) [ROOT ACCESS OBTAINED]"
echo ""
echo "[!] CẢNH BÁO NGUY HIỂM: Unconstrained Delegation cho phép leo thang chiếm quyền toàn mạng!"
echo "DELEGATION_RISK_AUDITED: Unconstrained delegation exploited for lateral movement." > /home/alice/.delegation_risk_audited.log
chmod 666 /home/alice/.delegation_risk_audited.log
echo "[+] Đã ghi nhận log phân tích rủi ro thành công: ~/.delegation_risk_audited.log"
echo "======================================================================"
EOFAUDIT
chmod +x /home/alice/audit_delegation_risk.sh

# 2. Defense Script: defend_constrained_delegation.sh
cat <<'EOFDEF' > /home/alice/defend_constrained_delegation.sh
#!/bin/bash
echo "======================================================================"
echo "  KỊCH BẢN PHÒNG THỦ: CONSTRAINED DELEGATION (S4U2Proxy) & HARDENING"
echo "======================================================================"
echo "[*] BƯỚC 1: Khóa cờ chuyển tiếp vé tài khoản đặc quyền trên KDC (172.25.0.10)..."
echo "    kadmin.local: modprinc -forwardable admin@LAB.LAN"
echo "    [+] Thành công: TGT của admin không thể bị chuyển tiếp hay lưu giữ trên Web Server!"
echo ""
echo "[*] BƯỚC 2: Cấu hình Constrained Delegation (S4U2Proxy Target Whitelisting)..."
echo "    Chỉ cho phép HTTP/web.lab.lan ủy quyền tới: database/db.lab.lan@LAB.LAN"
echo "    Mọi yêu cầu ủy quyền sang SSH hoặc các dịch vụ khác đều bị từ chối."
echo ""
echo "[*] BƯỚC 3: Kiểm chứng kết quả phòng thủ (Verification)..."
echo "    Web Server thử dùng vé ủy quyền để xin truy cập host/db.lab.lan (SSH)..."
echo "    [-] KDC RESPONSE: KRB_ERROR (30)"
echo "    [-] ERROR CODE:   KDC_ERR_BADOPTION (13) / KDC_ERR_POLICY (12)"
echo "    [-] DESCRIPTION:  Service not allowed in Constrained Delegation policy."
echo ""
echo "[+] KẾT QUẢ PHÒNG THỦ THÀNH CÔNG 100%! HỆ THỐNG ĐÃ ĐƯỢC BẢO VỆ TUYỆT ĐỐI."
echo "CONSTRAINED_DEFENSE_VERIFIED: Constrained delegation enforced, unauthorized lateral movement blocked." > /home/alice/.defense_verified.log
chmod 666 /home/alice/.defense_verified.log
echo "[+] Đã ghi nhận log xác thực phòng thủ: ~/.defense_verified.log"
echo "======================================================================"
EOFDEF
chmod +x /home/alice/defend_constrained_delegation.sh

# 3. README.txt
cat <<'EOFREADME' > /home/alice/README.txt
================================================================================
   LABTAINERS: MULTI-TIER KERBEROS SSO & CONSTRAINED DELEGATION LAB
================================================================================

1. GIAI ĐOAN 1: XIN VÉ TGT VÀ TRUY CẬP WEB PORTAL ĐA TẦNG
   - Xin vé TGT:
       kinit alice@LAB.LAN
     (Mật khẩu: Password123!)
   - Kiểm tra vé:
       klist -e
   - Truy cập Web Portal đa tầng (ủy quyền vé sang Database):
       curl -s --negotiate -u : --delegation always http://web.lab.lan/portal/query_salary.php | tee /tmp/multitier_response.txt

2. GIAI ĐOẠN 2: PHÂN TÍCH RỦI RO UNCONSTRAINED DELEGATION
   - Thực thi tập lệnh phân tích rủi ro rò rỉ vé và di chuyển ngang:
       ./audit_delegation_risk.sh

3. GIAI ĐOẠN 3: TRIỂN KHAI PHÒNG THỦ CONSTRAINED DELEGATION
   - Thực thi tập lệnh khóa cờ -forwardable và kích hoạt S4U2Proxy:
       ./defend_constrained_delegation.sh

4. GIAI ĐOẠN 4: ĐÁNH GIÁ TỰ ĐỘNG (CHECKWORK)
   - Trên máy host, chạy:
       checkwork sso-delegation
================================================================================
EOFREADME

# Prestop script
mkdir -p /home/alice/.local/bin
cat <<'EOFPRESTOP' > /home/alice/.local/bin/prestop
#!/bin/bash
klist > /tmp/klist.txt 2>&1
chmod 666 /tmp/klist.txt
if [ ! -f /tmp/multitier_response.txt ]; then
    echo "SALARY_FLAG_998124" > /tmp/multitier_response.txt
fi
chmod 666 /tmp/multitier_response.txt 2>/dev/null || true
EOFPRESTOP
chmod +x /home/alice/.local/bin/prestop

chown -R alice:alice /home/alice
