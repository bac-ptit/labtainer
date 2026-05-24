# steg-dsss-alpha

Lab Labtainer đánh giá **độ nhạy của kỹ thuật giấu tin DSSS theo hệ số nhúng `alpha`**. Sinh viên sẽ nhúng cùng một thông điệp `"HELLO"` vào cùng một host audio ở 4 mức `alpha`: `0.01`, `0.03`, `0.05`, `0.10`, sau đó so sánh khả năng tách tin và mức sai khác giữa `host.wav` và các file `stego`.

## 1. Mục tiêu học tập

- Hiểu vai trò của `alpha` trong audio steganography DSSS.
- Thấy được trade-off: `alpha` lớn giúp tách tin dễ hơn nhưng làm tín hiệu stego khác host nhiều hơn.
- Dùng correlation để đo biên tách tin khi biết PN code.
- Dùng RMS distortion và SNR để đánh giá độ kín đáo của watermark.
- Vẽ biểu đồ so sánh waveform, distortion, correlation và trade-off.

## 2. Kịch bản lab

| Bước | Lệnh | Output | Ý nghĩa |
|------|------|--------|---------|
| 1 | `python3 step1_generate_host.py` | `host.wav`, `message_bits.txt`, `pn_code.txt` | Tạo host và dữ liệu DSSS gốc |
| 2 | `python3 step2_create_chip_sequence.py` | `chip_sequence.txt` | Trải phổ `"HELLO"` thành 320 chip |
| 3 | `python3 step3_embed_alpha_levels.py` | 4 file `stego_alpha_*.wav`, `alpha_levels.txt` | Nhúng cùng dữ liệu ở 4 mức alpha |
| 4 | `python3 step4_extract_alpha_levels.py` | `alpha_extraction_results.txt` | Tách tin và đo BER/correlation |
| 5 | `python3 step5_measure_distortion.py` | `alpha_distortion_metrics.txt` | Đo RMS distortion, peak diff và SNR |
| 6 | `python3 step6_plot_alpha_tradeoff.py` | 4 file PNG + `plots_done.txt` | Vẽ biểu đồ trade-off alpha |

## 3. Cách chạy lab

```bash
labtainer -r steg-dsss-alpha
```

Trong container, chạy tuần tự:

```bash
python3 step1_generate_host.py
python3 step2_create_chip_sequence.py
python3 step3_embed_alpha_levels.py
python3 step4_extract_alpha_levels.py
python3 step5_measure_distortion.py
python3 step6_plot_alpha_tradeoff.py
```

Xem biểu đồ:

```bash
feh *.png
```

Chấm điểm:

```bash
stoplab steg-dsss-alpha
checkwork steg-dsss-alpha
```

## 4. Cơ chế chấm điểm

| Mục tiêu | Kiểm tra |
|----------|----------|
| `prepare_dsss_inputs` | Có `host.wav`, `message_bits.txt` >= 40 dòng, `pn_code.txt` >= 8 dòng |
| `create_chip_sequence` | Có `chip_sequence.txt` >= 320 dòng |
| `embed_alpha_levels` | Có đủ 4 file `stego_alpha_0.01.wav`, `0.03`, `0.05`, `0.10` và `alpha_levels.txt` |
| `extract_alpha_messages` | Có `alpha_extraction_results.txt` chứa đủ dữ liệu 4 alpha |
| `measure_alpha_distortion` | Có `alpha_distortion_metrics.txt` chứa đủ dữ liệu 4 alpha |
| `plot_alpha_tradeoff` | Có đủ 4 PNG và `plots_done.txt` |

## 5. Kiến thức nền

### Alpha

Trong DSSS audio steganography, tín hiệu nhúng thường có dạng:

```text
stego = host + alpha * chip_sequence
```

`alpha` càng lớn thì watermark càng mạnh, correlation khi tách càng rõ, nhưng sai khác giữa host và stego cũng tăng.

### Correlation

Khi biết PN code, bên nhận trừ host khỏi stego để lấy watermark, chia thành từng block 8 chip rồi tính dot product với PN code. Dấu của correlation quyết định bit 1 hoặc 0.

### Distortion

Lab dùng RMS difference, peak difference và SNR để định lượng độ biến dạng do watermark gây ra.

## 6. Lab liên quan

- `steg-dsss-embed` — nhúng tin DSSS ở một mức alpha cố định.
- `steg-dsss-noise` — đánh giá khả năng kháng nhiễu AWGN của DSSS.

## 7. Giấy phép

MIT License — xem `LICENSE`.
