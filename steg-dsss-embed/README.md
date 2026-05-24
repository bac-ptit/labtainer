# steg-dsss-embed

Lab Labtainer minh họa kỹ thuật **giấu tin trong âm thanh (audio steganography) bằng phương pháp DSSS (Direct Sequence Spread Spectrum)**. Sinh viên sẽ giấu chuỗi `"HELLO"` vào một sóng sin host, đồng thời vẽ các biểu đồ trực quan hóa từng bước của quá trình nhúng tin.

Lab này là phần *embed* (nhúng tin), đi kèm với lab `steg-dsss-extract` (tách tin) đã có trong Labtainers.

## 1. Mục tiêu học tập

Sau khi hoàn thành lab, sinh viên hiểu được:

- Cách biểu diễn thông điệp dưới dạng chuỗi bit nhị phân.
- Cách sinh và sử dụng **PN code** (Pseudo-Noise) để trải phổ.
- Bản chất của **DSSS spreading**: nhân bit tin với chip code để dàn trải năng lượng tín hiệu trên dải tần rộng.
- Cách nhúng chuỗi chip vào một tín hiệu host (sóng sin) ở cường độ rất nhỏ để khó phát hiện bằng tai.
- Quan sát ảnh hưởng của DSSS qua miền thời gian và miền tần số (FFT).

## 2. Kịch bản lab

Lab chạy 6 bước Python tuần tự bên trong container `students`:

| Bước | Lệnh | Output | Ý nghĩa |
|------|------|--------|---------|
| 1 | `python3 step1_create_host.py` | `host.wav` | Sinh sóng sin 440 Hz, 16 kHz, 5 giây làm tín hiệu chứa |
| 2 | `python3 step2_message_to_bits.py` | `message_bits.txt` (40 bit) | Mã hóa `"HELLO"` thành 5 × 8 = 40 bit |
| 3 | `python3 step3_generate_pn.py` | `pn_code.txt` (8 chip) | Sinh PN code dùng chung với lab `steg-dsss-extract` |
| 4 | `python3 step4_spread.py` | `chip_sequence.txt` (320 chip) | Trải phổ DSSS: bit `1` → giữ PN, bit `0` → đảo PN |
| 5 | `python3 step5_embed.py` | `stego.wav` | Nhúng chuỗi chip vào host với cường độ `alpha = 0.05` |
| 6 | `python3 step6_plot_signals.py` | 6 file `.png` + `plots_done.txt` | Vẽ 6 biểu đồ minh họa |

### 6 biểu đồ sinh ra ở bước 6

- `01_host_sine.png` – sóng sin host gốc (400 mẫu đầu).
- `02_pn_sequence.png` – chuỗi PN code 8 chip.
- `03_message_bits.png` – 40 bit của `"HELLO"`.
- `04_chip_sequence.png` – 64 chip đầu sau khi trải phổ.
- `05_stego_vs_host.png` – so sánh host vs stego trong miền thời gian.
- `06_spectrum.png` – phổ FFT host vs stego (0 – 2000 Hz).

Xem ảnh trong container (đã cài sẵn 3 cách):

```bash
feh *.png                   # nhe, xem ca 6 anh, n/p de chuyen
eog 01_host_sine.png        # mo tung anh trong Eye of GNOME
xdg-open 06_spectrum.png    # tu chon viewer mac dinh
```

## 3. Cách chạy lab

> Yêu cầu: đã cài Labtainer student (xem `labtainer-student.pdf`).

Sao chép thư mục lab này vào không gian labs của Labtainer, ví dụ:

```bash
cp -r ~/Documents/steg-dsss-embed ~/labtainer/trunk/labs/
```

Hoặc nếu nhận file `.tar.gz` từ Moodle:

```bash
tar -xzf steg-dsss-embed.tar.gz -C ~/labtainer/trunk/labs/
```

Sau đó khởi động lab:

```bash
labtainer steg-dsss-embed
```

Bên trong container, chạy lần lượt 6 bước:

```bash
python3 step1_create_host.py
python3 step2_message_to_bits.py
python3 step3_generate_pn.py
python3 step4_spread.py
python3 step5_embed.py
python3 step6_plot_signals.py
```

Xong rồi chấm điểm:

```bash
stoplab steg-dsss-embed
checkwork steg-dsss-embed
```

Khởi động lại lab từ đầu (xóa tiến độ cũ):

```bash
labtainer steg-dsss-embed -r
```

## 4. Cơ chế chấm điểm

Lab có **đúng 6 mục tiêu** ánh xạ 1-1 với 6 bước, tên có ý nghĩa rõ ràng:

| Mục tiêu | Tương ứng bước |
|----------|----------------|
| `create_host_signal` | Step 1 — tạo `host.wav` |
| `encode_message_to_bits` | Step 2 — mã hóa "HELLO" → 40 bit |
| `generate_pn_code` | Step 3 — sinh PN code 8 chip |
| `spread_dsss_chips` | Step 4 — trải phổ DSSS → 320 chip |
| `embed_stego_audio` | Step 5 — nhúng chip vào host → `stego.wav` |
| `visualize_dsss_plots` | Step 6 — vẽ đủ 6 file PNG |

Mỗi mục tiêu chỉ PASS khi `pregrade.sh` xác nhận đồng thời:

1. Sinh viên đã chạy đúng file step (kiểm qua `.bash_history`).
2. Artifact sinh ra hợp lệ về định dạng / số dòng.

Các kiểm tra artifact trong `instr_config/pregrade.sh`:

- `host.wav` và `stego.wav` phải là file WAV hợp lệ (`file ... | grep WAVE audio`).
- `message_bits.txt` >= 40 dòng.
- `pn_code.txt` >= 8 dòng.
- `chip_sequence.txt` >= 320 dòng (40 bit x 8 chip).
- Đủ 6 file PNG và file flag `plots_done.txt`.

Khi chạy `checkwork steg-dsss-embed`, output sẽ chỉ hiển thị 6 dòng tương ứng 6 mục tiêu trên — không có các result trung gian rối mắt.

## 5. Cấu trúc thư mục

```
steg-dsss-embed/
├── README.md
├── config/
│   ├── start.config            # Khai báo container students, registry, X11
│   ├── parameter.config
│   └── students-home_tar.list
├── dockerfiles/
│   └── Dockerfile.steg-dsss-embed.students.student
├── docs/
│   └── read_first.txt          # Mô tả lab cho sinh viên (tiếng Việt)
├── instr_config/
│   ├── goals.config            # 6 mục tiêu chấm điểm (tên có nghĩa)
│   ├── results.config          # Quy tắc trích kết quả
│   └── pregrade.sh             # Kiểm artifact + history trước khi chấm
└── students/
    ├── _bin/fixlocal.sh
    ├── _system/etc/...
    ├── home_tar/home.tar
    ├── sys_tar/sys.tar
    ├── step1_create_host.py
    ├── step2_message_to_bits.py
    ├── step3_generate_pn.py
    ├── step4_spread.py
    ├── step5_embed.py
    └── step6_plot_signals.py
```

## 6. Phụ thuộc

Container kế thừa image `labtainer.base2` của Labtainer và cài thêm:

- `python3-pip`, `python3-numpy`, `python3-scipy`, `python3-matplotlib`, `python3-soundfile` — tính toán DSSS và vẽ biểu đồ.
- `feh`, `eog`, `xdg-utils` — xem ảnh PNG ngay trong container (`feh *.png` xem nhanh cả 6 ảnh).

Bật `X11 YES` trong `config/start.config` để các viewer có thể hiển thị ảnh.

## 7. Tham số có thể chỉnh

Có thể đổi nhanh trong các file step:

- `step1_create_host.py`: `SAMPLE_RATE`, `DURATION`, `FREQ`, `AMPLITUDE`.
- `step2_message_to_bits.py`: biến `MESSAGE` (lưu ý đổi message sẽ thay đổi số bit và độ dài chip — phải cập nhật ngưỡng trong `pregrade.sh` cho khớp).
- `step3_generate_pn.py`: chuỗi PN code (cần đồng bộ với lab `steg-dsss-extract`).
- `step5_embed.py`: `ALPHA` — cường độ nhúng. Alpha lớn dễ tách hơn nhưng dễ phát hiện bằng tai.

## 8. Lab liên quan

- `steg-dsss-extract` – tách tin từ `stego.wav` bằng cùng PN code.

## 9. Giấy phép

MIT License — xem `LICENSE`.
