# Minh chung lab steg-dsss-detect

## Thong tin lab

- Ten lab: `steg-dsss-detect`
- Huong bai: phat hien watermark DSSS trong audio bang sliding correlation.
- Khac voi `steg-dsss-embed`: bai nay khong yeu cau sinh vien nhung tin, ma phai phan biet `clean_test.wav` va `stego_test.wav`.

## Cac buoc thuc hien

```bash
python3 step1_prepare_audio.py
python3 step2_generate_signature.py
python3 step3_detect_watermark.py
python3 step4_plot_detection.py
python3 step5_write_summary.py
```

## Output chinh

- `host.wav`
- `clean_test.wav`
- `stego_test.wav`
- `pn_code.txt`
- `message_bits.txt`
- `chip_sequence.txt`
- `detection_scores.txt`
- `detection_report.txt`
- `student_summary.txt`
- `01_test_audio_waveforms.png`
- `02_dsss_signature.png`
- `03_detection_scores.png`
- `04_correlation_traces.png`

## Ket qua detector da verify

```text
DSSS watermark detection
Threshold: 0.4
clean_test.wav -> CLEAN (score 0.016 at offset 58249)
stego_test.wav -> WATERMARK_PRESENT (score 0.970 at offset 2400)
```

## Ket qua pregrade

```text
AUDIO_OK
SIGNATURE_OK
DETECT_OK
PLOTS_OK
SUMMARY_OK
```

## Muc tieu cham diem

- `prepare_detection_audio`
- `create_dsss_signature`
- `run_watermark_detector`
- `plot_detection_results`
- `write_detection_summary`
