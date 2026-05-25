# scene-h264-stego

Lab Labtainer ve **giau tin trong video dua tren thay doi khung canh va video H.264**. Sinh vien tao video co nhieu scene cut, phat hien cac vi tri chuyen canh, nhung bit thong diep vao frame ngay sau scene cut, ma hoa lai bang H.264, trich xuat thong diep va danh gia chat luong video.

## 1. Muc tieu hoc tap

- Hieu vi sao scene-change la vi tri co the dung de giau tin trong video.
- Tao video cover co cac doan khung canh ro rang va encode bang H.264.
- Phat hien scene cut bang frame-difference.
- Nhung bit vao cac frame sau scene cut bang patch sang/toi nho.
- Trich xuat thong diep sau khi video da qua H.264.
- Kiem tra codec H.264, PSNR va kich thuoc file.

## 2. Cac buoc chay

| Buoc | Lenh | Output |
|------|------|--------|
| 1 | `python3 step1_create_cover_video.py` | `cover_h264.mp4`, `cover_frames/` |
| 2 | `python3 step2_detect_scene_changes.py cover_h264.mp4` | `scene_changes.txt`, `selected_frames.txt` |
| 3 | `python3 step3_message_to_bits.py message.txt` | `message_bits.txt` |
| 4 | `python3 step4_embed_scene_bits.py cover_h264.mp4 selected_frames.txt message_bits.txt` | `stego_h264.mp4`, `embed_map.txt` |
| 5 | `python3 step5_extract_scene_bits.py stego_h264.mp4 embed_map.txt` | `recovered_bits.txt`, `recovered_message.txt` |
| 6 | `python3 step6_evaluate_h264_quality.py cover_h264.mp4 stego_h264.mp4` | `quality_report.txt`, `h264_report.txt` |

## 3. Cach chay lab

```bash
labtainer scene-h264-stego
```

Trong container:

```bash
python3 step1_create_cover_video.py
python3 step2_detect_scene_changes.py cover_h264.mp4
python3 step3_message_to_bits.py message.txt
python3 step4_embed_scene_bits.py cover_h264.mp4 selected_frames.txt message_bits.txt
python3 step5_extract_scene_bits.py stego_h264.mp4 embed_map.txt
python3 step6_evaluate_h264_quality.py cover_h264.mp4 stego_h264.mp4
```

Kiem tra:

```bash
stoplab scene-h264-stego
checkwork scene-h264-stego
```

## 4. Checkwork

Lab co 6 muc:

- `create_cover_h264`
- `detect_scene_changes`
- `encode_secret_bits`
- `embed_scene_stego`
- `extract_hidden_message`
- `evaluate_h264_quality`

## 5. Y tuong ky thuat

Scene cut tao ra thay doi lon giua hai frame lien tiep, nen cac bien doi nho tai frame sau scene cut it bi chu y hon so voi doan canh tinh. Lab nay chon cac frame ngay sau scene cut lam vi tri nhung. Moi bit duoc ma hoa bang mot patch nho: bit `1` la patch sang, bit `0` la patch toi. Video sau do duoc encode bang H.264 lossless (`libx264 -crf 0`) de sinh vien thay duoc pipeline H.264 va van trich xuat on dinh.

## 6. Giay phep

MIT License - xem `LICENSE`.

## 7. Tham khao

- FFmpeg/ffprobe documentation: https://ffmpeg.org/ffprobe.html
- FFmpeg filters documentation, co ho tro scene expression trong filter `select`: https://ffmpeg.org/ffmpeg-filters.html
- Tong quan nghien cuu H.264 video steganography dua tren motion vector/DCT/entropy coding: https://link.springer.com/article/10.1007/s11042-024-18651-9
