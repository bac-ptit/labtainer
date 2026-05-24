# steg-dsss-noise

Lab Labtainer đánh giá **khả năng kháng nhiễu của kỹ thuật giấu tin DSSS** (Direct Sequence Spread Spectrum). Sinh viên sẽ thêm nhiễu Gaussian (AWGN) vào tín hiệu stego ở nhiều mức SNR, sau đó trích xuất message và tính BER (Bit Error Rate) để đánh giá robustness.

## 1. Mục tiêu học tập

- Hiểu khái niệm **AWGN** (Additive White Gaussian Noise) và **SNR** (Signal-to-Noise Ratio).
- Hiểu **BER** (Bit Error Rate) — thước đo chất lượng truyền tin.
- Hiểu **Processing Gain** của DSSS: PG = chips/bit = 8 → 9 dB.
- Quan sát ngưỡng SNR mà DSSS bắt đầu mất khả năng tách tin.
- Phân tích correlation-based detection dưới tác động của nhiễu.

## 2. Kịch bản lab

| Bước | Lệnh | Output | Ý nghĩa |
|------|------|--------|---------|
| 1 | `python3 step1_prepare_stego.py` | `stego.wav`, `host.wav`, `pn_code.txt`, `message_bits.txt` | Tạo tín hiệu stego (nhúng "HELLO" bằng DSSS) |
| 2 | `python3 step2_add_noise.py` | `noisy_snr{X}dB.wav` (8 file) | Thêm AWGN ở 8 mức SNR: 50, 40, 30, 20, 15, 10, 5, 0 dB |
| 3 | `python3 step3_extract_from_noisy.py` | `extraction_results.txt` | Trích xuất message từ mỗi file noisy, tính BER |
| 4 | `python3 step4_plot_ber.py` | 4 file `.png` | Vẽ biểu đồ phân tích kháng nhiễu |

### 4 biểu đồ sinh ra

- `01_ber_vs_snr.png` — BER theo SNR (đồ thị chính, thang log).
- `02_signal_comparison.png` — So sánh host / stego / noisy (SNR thấp nhất).
- `03_spectrum_noisy.png` — Phổ FFT stego vs noisy.
- `04_correlation_map.png` — Giá trị correlation mỗi bit tại các mức SNR.

## 3. Cách chạy lab

```bash
# Cai dat
tar -xzf steg-dsss-noise.tar.gz -C ~/labtainer/trunk/labs/
labtainer steg-dsss-noise

# Trong container
python3 step1_prepare_stego.py
python3 step2_add_noise.py
python3 step3_extract_from_noisy.py
python3 step4_plot_ber.py

# Xem bieu do
feh *.png

# Cham diem
stoplab steg-dsss-noise
checkwork steg-dsss-noise
```

## 4. Cơ chế chấm điểm

| Mục tiêu | Kiểm tra |
|----------|----------|
| `prepare_stego_signal` | `stego.wav` + `host.wav` hợp lệ, có `pn_code.txt` + `message_bits.txt` |
| `generate_noisy_signals` | >= 4 file `noisy_snr*dB.wav` + `snr_levels.txt` |
| `extract_and_compute_ber` | `extraction_results.txt` >= 5 dòng (header + data) |
| `visualize_ber_analysis` | Đủ 4 file PNG + `plots_done.txt` |

## 5. Kiến thức nền

### AWGN (Additive White Gaussian Noise)
Nhiễu trắng Gaussian — mô hình nhiễu phổ biến nhất trong truyền thông. Phổ phẳng trên toàn dải tần, biên độ tuân theo phân phối chuẩn.

### SNR (Signal-to-Noise Ratio)
```
SNR(dB) = 10 * log10(P_signal / P_noise)
```
SNR cao = ít nhiễu, SNR thấp = nhiều nhiễu.

### BER (Bit Error Rate)
```
BER = số bit lỗi / tổng số bit
```
BER = 0 → tách tin hoàn hảo. BER = 0.5 → tương đương đoán ngẫu nhiên.

### Processing Gain
DSSS có khả năng kháng nhiễu nhờ spreading. Processing Gain:
```
PG = chips_per_bit = 8 → 10*log10(8) = 9 dB
```
Nghĩa là DSSS có thể chịu thêm ~9 dB nhiễu so với không trải phổ.

## 6. Lab liên quan

- `steg-dsss-embed` — nhúng tin bằng DSSS (bước chuẩn bị).
- `steg-dsss-extract` — trích xuất tin (không có nhiễu).

## 7. Giấy phép

MIT License — xem `LICENSE`.
