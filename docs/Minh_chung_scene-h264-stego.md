# Minh chung lab scene-h264-stego

## Thong tin lab

- Ten lab: `scene-h264-stego`
- Chu de: giau tin trong video dua tren scene-change va video H.264.
- Huong thuc hien: chon frame ngay sau scene-change, nhung bit bang patch sang/toi nho, encode lai bang H.264 lossless, trich xuat thong diep tu video stego.
- Docker image: `hoangbac2004/scene-h264-stego.students.student:latest`
- Imodule: `scene-h264-stego-hoangbac2004-imodule.tar`

## Lenh tai va chay

```bash
imodule https://raw.githubusercontent.com/bac-ptit/labtainer/main/scene-h264-stego-hoangbac2004-imodule.tar
docker pull hoangbac2004/scene-h264-stego.students.student:latest
labtainer -r scene-h264-stego
```

## Lenh chay

```bash
python3 step1_create_cover_video.py
python3 step2_detect_scene_changes.py cover_h264.mp4
python3 step3_message_to_bits.py message.txt
python3 step4_embed_scene_bits.py cover_h264.mp4 selected_frames.txt message_bits.txt
python3 step5_extract_scene_bits.py stego_h264.mp4 embed_map.txt
python3 step6_evaluate_h264_quality.py cover_h264.mp4 stego_h264.mp4
```

## Ket qua verify

```text
Created cover_h264.mp4 with 180 frames at 12 fps
Selected scene-change frames: 179
Message: SCENE_H264_STEGO_OK
Bits: 152
Embedded bits: 152
Recovered message: SCENE_H264_STEGO_OK
Cover codec: h264
Stego codec: h264
PSNR: 28.568 dB
```

## Ket qua pregrade

```text
COVER_OK
SCENE_OK
BITS_OK
EMBED_OK
EXTRACT_OK
QUALITY_OK
```

## Docker push

```text
docker push hoangbac2004/scene-h264-stego.students.student:latest
latest: digest: sha256:a56d8ca1ccd9877291d750bf52a03decb5199bd4e8bb3365fd81f2abd03fcfa8 size: 7606
```

## Checkwork

- `create_cover_h264`
- `detect_scene_changes`
- `encode_secret_bits`
- `embed_scene_stego`
- `extract_hidden_message`
- `evaluate_h264_quality`
