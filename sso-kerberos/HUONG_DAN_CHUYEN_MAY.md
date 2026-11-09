# 📖 HƯỚNG DẪN CHUYỂN BÀI LAB SANG MÁY KHÁC VÀ CÁCH KHỞI CHẠY
*(Tài liệu ghi nhớ từng bước dành cho sinh viên thực hiện đồ án tốt nghiệp)*

---

## 📌 BẠN CẦN COPY FILE NÀO MANG THEO?

Trong thư mục `sso-kerberos/` của máy hiện tại, bạn chỉ cần copy **DUY NHẤT 1 FILE**:
👉 **`sso-kerberos-lab-source.zip`** *(Dung lượng siêu nhẹ: chỉ **112 KB**)*

Bạn có thể gửi file này qua Zalo, Email, Google Drive hoặc USB để mang sang máy tính mới.

---

## 🚀 CÁCH CÀI ĐẶT TRÊN MÁY TÍNH MỚI (TỪNG BƯỚC CỤ THỂ)

> **Điều kiện tiên quyết trên máy mới:**  
> Máy tính mới của bạn đã cài đặt môi trường **Labtainers** (thường là máy ảo Ubuntu đã có sẵn Labtainers trong thư mục `/home/student/labtainer`).

### BƯỚC 1: ĐẶT BÀI LAB VÀO ĐÚNG THƯ MỤC TRÊN MÁY MỚI
1. Mở Terminal trên máy mới.
2. Giả sử bạn tải file `sso-kerberos-lab-source.zip` về thư mục `Downloads` (hoặc Desktop), hãy chạy lệnh giải nén trực tiếp vào thư mục labs của Labtainers:

```bash
# Giải nén trực tiếp vào thư mục labs của Labtainers:
unzip ~/Downloads/sso-kerberos-lab-source.zip -d /home/student/labtainer/trunk/labs/
```

*(Sau khi giải nén, thư mục bài lab sẽ nằm chính xác tại: `/home/student/labtainer/trunk/labs/sso-kerberos`)*

---

### BƯỚC 2: KHỞI CHẠY BÀI LAB TRÊN MÁY MỚI
Chuyển vào thư mục làm việc của sinh viên và khởi động:

```bash
cd /home/student/labtainer/labtainer-student
labtainer sso-kerberos
```

*Hoặc nếu lệnh `labtainer` chưa nạp biến môi trường, bạn chạy lệnh chuẩn:*
```bash
cd /home/student/labtainer/labtainer-student
/opt/labtainer/venv/bin/python bin/start.py sso-kerberos
```

> ⏳ **Lưu ý:** Lần đầu tiên chạy trên máy mới, Labtainers sẽ mất khoảng **1 - 3 phút** để tự động build 4 container Docker (`kdc`, `web`, `ssh`, `client`) từ các tệp cấu hình có sẵn trong thư mục 112 KB này.

---

### BƯỚC 3: TRUY CẬP VÀ DEMO BÀI LAB
Sau khi hệ thống khởi động thành công 4 container, bạn mở một terminal mới để vào máy trạm sinh viên (`alice`):

```bash
# Vào máy trạm sinh viên:
docker exec -it -u alice sso-kerberos.client.student bash

# 1. Lấy vé Kerberos TGT (Mật khẩu: Password123!):
kinit alice
klist

# 2. Truy cập Web SSO (Không cần mật khẩu, trả về HTTP 200 OK kèm Flag):
curl -i --negotiate -u : http://web.lab.lan/intranet/index.html

# 3. Đăng nhập SSH SSO (Đăng nhập tức thì không hỏi mật khẩu):
ssh alice@ssh.lab.lan
klist
exit

# 4. Thực hành bẻ khóa AS-REP Roasting:
./attack_asrep_roast.sh

# 5. Thoát khỏi container client:
exit
```

---

### BƯỚC 4: CHẤM ĐIỂM TỰ ĐỘNG (KIỂM TRA HOÀN THÀNH)
Từ terminal máy host (bên ngoài container), chạy:

```bash
checkwork sso-kerberos
```
👉 Kết quả sẽ báo: **`100% COMPLETED (4/4 GOALS Y)`**.

---

### BƯỚC 5: DỪNG BÀI LAB KHI KHÔNG SỬ DỤNG
Khi làm xong hoặc trước khi tắt máy, chạy:

```bash
stoplab sso-kerberos
```

---

## ⚠️ TRƯỜNG HỢP ĐẶC BIỆT: MÁY MỚI KHÔNG CÓ KẾT NỐI INTERNET

Nếu máy tính mới hoàn toàn **không có mạng Internet** để Labtainers tải các gói cập nhật khi build lần đầu:
1. **Trên máy cũ (máy hiện tại):** Bạn xuất 4 Docker images ra file nén USB:
   ```bash
   docker save sso-kerberos.kdc.student sso-kerberos.web.student sso-kerberos.ssh.student sso-kerberos.client.student | gzip > sso-kerberos-docker-images.tar.gz
   ```
2. **Trên máy mới:** Cắm USB vào và nạp images vào Docker:
   ```bash
   docker load < sso-kerberos-docker-images.tar.gz
   ```
   *(Sau đó giải nén file zip 112 KB vào `/home/student/labtainer/trunk/labs/` và chạy `labtainer sso-kerberos` hoàn toàn offline 100%).*
