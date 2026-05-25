# steg-dsss-detect

Lab Labtainer ve **phat hien watermark DSSS trong audio**. Khac voi `steg-dsss-embed`, lab nay khong tap trung vao nhung tin, ma yeu cau sinh vien dung correlation/de-spreading de xac dinh file audio nao co chua watermark DSSS.

## 1. Muc tieu hoc tap

Sau khi hoan thanh lab, sinh vien co the:

- Tao bo du lieu kiem thu gom `host.wav`, `clean_test.wav`, `stego_test.wav`.
- Hieu vai tro cua PN code trong viec phat hien watermark DSSS.
- Tinh correlation giua watermark ung vien va chuoi chip DSSS.
- Dat nguong phat hien de phan biet audio sach va audio co watermark.
- Doc bao cao detection va bieu do correlation peak.

## 2. Kich ban lab

Lab chay 5 buoc Python trong container `students`:

| Buoc | Lenh | Output | Y nghia |
|------|------|--------|---------|
| 1 | `python3 step1_prepare_audio.py` | `host.wav`, `clean_test.wav`, `stego_test.wav` | Tao audio sach va audio co watermark an |
| 2 | `python3 step2_generate_signature.py` | `pn_code.txt`, `message_bits.txt`, `chip_sequence.txt` | Tao DSSS signature dung de detect |
| 3 | `python3 step3_detect_watermark.py` | `detection_scores.txt`, `detection_report.txt` | Tinh correlation va ket luan file nao co watermark |
| 4 | `python3 step4_plot_detection.py` | 4 file PNG + `plots_done.txt` | Ve audio, chip, score va correlation |
| 5 | `python3 step5_write_summary.py` | `student_summary.txt` | Tom tat ket qua detect va nguong |

## 3. Cach chay

```bash
labtainer steg-dsss-detect
```

Trong terminal container, chay lan luot:

```bash
python3 step1_prepare_audio.py
python3 step2_generate_signature.py
python3 step3_detect_watermark.py
python3 step4_plot_detection.py
python3 step5_write_summary.py
```

Kiem tra diem:

```bash
stoplab steg-dsss-detect
checkwork steg-dsss-detect
```

Khoi dong lai tu dau:

```bash
labtainer steg-dsss-detect -r
```

## 4. Cham diem

Lab co 5 muc tieu:

| Muc tieu | Dieu kien chinh |
|----------|-----------------|
| `prepare_detection_audio` | Co du 3 file WAV hop le |
| `create_dsss_signature` | Co PN code, message bits va chip sequence |
| `run_watermark_detector` | Co score/report va report phat hien dung `stego_test.wav` |
| `plot_detection_results` | Co du 4 file PNG va flag `plots_done.txt` |
| `write_detection_summary` | Co `student_summary.txt` tom tat ket qua |

## 5. File quan trong

```
steg-dsss-detect/
├── README.md
├── config/
│   ├── start.config
│   ├── parameter.config
│   └── students-home_tar.list
├── dockerfiles/
│   └── Dockerfile.steg-dsss-detect.students.student
├── docs/
│   └── read_first.txt
├── instr_config/
│   ├── goals.config
│   ├── results.config
│   └── pregrade.sh
└── students/
    ├── step1_prepare_audio.py
    ├── step2_generate_signature.py
    ├── step3_detect_watermark.py
    ├── step4_plot_detection.py
    └── step5_write_summary.py
```

## 6. Khac voi steg-dsss-embed

`steg-dsss-embed` huong dan tao file stego tu message. Lab nay cho sinh vien nhin bai toan nguoc: khi co audio nghi van va biet DSSS signature, phai dung correlation de phat hien watermark co ton tai hay khong.

## 7. Giay phep

MIT License - xem `LICENSE`.
