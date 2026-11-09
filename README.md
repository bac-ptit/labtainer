# Hệ Thống Bài Thực Hành An Toàn Thông Tin & Kerberos SSO Labtainer

**Sinh viên thực hiện:** Hoàng Văn Bắc  
**Mã sinh viên:** B22DCAT035 (Lớp: D22CQAT035 -B)  
**Giảng viên hướng dẫn:** TS. Quản Trọng Thế  
**Đơn vị:** Học viện Công nghệ Bưu chính Viễn thông (PTIT)  
**Tài khoản lưu trữ Docker Hub:** [hoangbac2004](https://hub.docker.com/u/hoangbac2004)  
**Tài khoản lưu trữ GitHub:** [bac-ptit](https://github.com/bac-ptit)

---

## 🔐 Phần 1: Bộ 8 Bài Lab Chuyên Sâu Về SSO & Kerberos Authentication (Enterprise Identity Suite)

Bộ 8 bài lab mô phỏng toàn diện các kiến trúc Đăng nhập một lần (Single Sign-On - SSO), quản lý danh tính tập trung Kerberos, phân tích rủi ro an ninh theo khung **MITRE ATT&CK**, và triển khai các kỹ thuật phòng thủ Blue Team chuẩn hóa trong môi trường mạng doanh nghiệp thực tế.

| STT | Bài Lab | Kiến trúc SSO & Dịch vụ | Kịch bản Tấn công (Red Team) | Giải pháp Phòng thủ (Blue Team) | Báo cáo Học thuật |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **01** | `sso-kerberos` | Web SPNEGO (Apache) & Shell SSH SSO | AS-REP Roasting (MITRE T1558.004) nhắm tài khoản tắt Pre-Auth | Bắt buộc `+requires_preauth`, KDC trả mã lỗi 25, chuẩn AES-256 | [📄 Báo cáo .docx](docs/reports/Thực%20hành%20Labtainer.docx) \| [📕 .pdf](docs/reports/Thực%20hành%20Labtainer.pdf) |
| **02** | `sso-delegation` | Multi-tier SSO (Client → Web Frontend → Backend DB) | Khai thác Unconstrained Delegation, trích xuất ccache chiếm quyền root | Chặn vé chuyển tiếp (`modprinc -forwardable`), kích hoạt Constrained S4U2Proxy | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_Delegation.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_Delegation.pdf) |
| **03** | `sso-pkinit` | Passwordless SSO qua Chứng chỉ số X.509 (RFC 4556) | Cố tình nạp chứng chỉ giả mạo hoặc chứng chỉ đã bị thu hồi (Revoked) | Kiểm tra CRL thời gian thực, đối soát SAN và xóa mật khẩu tĩnh (`-nokey`) | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_PKINIT.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_PKINIT.pdf) |
| **04** | `sso-crossrealm` | SSO Liên miền (Inter-realm Trust: STUDENT.LAB ↔ RESEARCH.LAB) | Lợi dụng vé chéo trái phép, mạo danh người dùng không thuộc danh sách phê duyệt | Cô lập phân quyền qua `.k5login`, thu hồi khóa vé chéo, chuẩn AES-256 | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_CrossRealm.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_CrossRealm.pdf) |
| **05** | `sso-kerberoasting` | SSO Doanh nghiệp với Tài khoản dịch vụ SPN | Kerberoasting (MITRE T1558.003): Xin vé TGS và bẻ khóa offline mật khẩu yếu | Thiết lập chính sách mật khẩu phức tạp >20 ký tự và chuyển dịch sang AES-256 | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_Kerberoasting.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_Kerberoasting.pdf) |
| **06** | `sso-passtheticket` | SSO Trạm làm việc đa người dùng (Shared Workstation) | Pass-the-Ticket (MITRE T1558.001): Trộm ccache từ `/tmp/krb5cc_*` | Chuyển đổi bộ nhớ vé sang Linux Kernel Keyring (`KEYRING:persistent:%{uid}`) | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_PassTheTicket.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_PassTheTicket.pdf) |
| **07** | `sso-silverticket` | SSO Ứng dụng Web Intranet với Keytab | Silver Ticket (MITRE T1558.002): Trích xuất Keytab lộ lọt, rèn vé TGS giả | Phân quyền bảo vệ Keytab (`chmod 400`) & Xoay vòng khóa dịch vụ (Keytab Rotation kvno 2) | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_SilverTicket.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_SilverTicket.pdf) |
| **08** | `sso-replay-skew` | Đồng bộ thời gian Kerberos & Replay Protection | Tấn công Replay vé xác thực AP-REQ và thử nghiệm sai lệch đồng hồ Clock Skew | Chặn đứng sai lệch thời gian (>300s: lỗi 37) và kích hoạt Replay Cache (lỗi 34) | [📄 Báo cáo .docx](docs/reports/Bao_cao_Nho_SSO_ReplaySkew.docx) \| [📕 .pdf](docs/reports/Bao_cao_Nho_SSO_ReplaySkew.pdf) |

---

### Hướng Dẫn Cài Đặt & Thực Hiện Các Bài Lab Kerberos SSO

#### Cách 1: Cài đặt trực tiếp qua `imodule`
```bash
# Bài 1: SSO Cơ bản & AS-REP Roasting
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-kerberos-hoangbac2004-imodule.tar

# Bài 2: Ticket Delegation & Unconstrained Delegation Risk
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-delegation-hoangbac2004-imodule.tar

# Bài 3: Passwordless SSO PKINIT (X.509 CA)
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-pkinit-hoangbac2004-imodule.tar

# Bài 4: Liên miền Cross-Realm Trust SSO
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-crossrealm-hoangbac2004-imodule.tar

# Bài 5: TGS Kerberoasting Attack & Hardening
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-kerberoasting-hoangbac2004-imodule.tar

# Bài 6: Pass-the-Ticket & Linux Kernel Keyring
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-passtheticket-hoangbac2004-imodule.tar

# Bài 7: Silver Ticket Forgery & Keytab Rotation
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-silverticket-hoangbac2004-imodule.tar

# Bài 8: Clock Skew Enforcement & Replay Cache
imodule https://github.com/bac-ptit/labtainer/raw/main/sso-replay-skew-hoangbac2004-imodule.tar
```

#### Cách 2: Khởi chạy và chấm điểm tự động trong Labtainer
```bash
# Khởi động bài lab (ví dụ: sso-kerberos)
labtainer -r sso-kerberos

# Kiểm tra kết quả thực hành tự động (chấm điểm tự động)
checkwork
```

---

## 🖼️ Phần 2: Sơ Đồ Kiến Trúc Hệ Thống (Architecture Diagrams)

Các sơ đồ kiến trúc độ phân giải cao được lưu trữ tại thư mục [`docs/diagrams/`](docs/diagrams/):
- **SSO Delegation:** [`architecture_sso_delegation.png`](docs/diagrams/architecture_sso_delegation.png)
- **SSO PKINIT:** [`architecture_sso_pkinit.png`](docs/diagrams/architecture_sso_pkinit.png)
- **SSO Cross-Realm:** [`architecture_sso_crossrealm.png`](docs/diagrams/architecture_sso_crossrealm.png)
- **SSO Kerberoasting:** [`architecture_sso_kerberoasting.png`](docs/diagrams/architecture_sso_kerberoasting.png)
- **SSO Pass-the-Ticket:** [`architecture_sso_passtheticket.png`](docs/diagrams/architecture_sso_passtheticket.png)
- **SSO Silver Ticket:** [`architecture_sso_silverticket.png`](docs/diagrams/architecture_sso_silverticket.png)
- **SSO Replay Skew:** [`architecture_sso_replayskew.png`](docs/diagrams/architecture_sso_replayskew.png)

---

## 🎬 Phần 3: Các Bài Lab Giấu Tin Video & DSSS Steganography Trước Đó

Cài đặt các bài lab giấu tin DSSS & H.264 Steganography trực tiếp với `imodule`:

```bash
imodule https://github.com/bac-ptit/labtainer/raw/main/steg-dsss-embed.tar
imodule https://github.com/bac-ptit/labtainer/raw/main/steg-dsss-noise.tar
imodule https://github.com/bac-ptit/labtainer/raw/main/steg-dsss-alpha.tar
```

Chạy các bài lab:

```bash
labtainer -r steg-dsss-embed
labtainer -r steg-dsss-noise
labtainer -r steg-dsss-alpha
```

Gói imodule tổng hợp:

```bash
imodule https://github.com/bac-ptit/labtainer/raw/main/steg-dsss-hoangbac2004-imodule.tar
imodule https://github.com/bac-ptit/labtainer/raw/main/steg-dsss-all-dsss-imodule.tar
```
