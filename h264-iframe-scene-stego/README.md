# h264-iframe-scene-stego

Lab Labtainer ve **giau tin vao I-frame tai diem hard scene cut trong video H.264**. Lab tao video co chuyen canh dot ngot, phat hien scene cut, chon cac frame sau scene cut lam I-frame target, nhung thong diep vao patch mo phong DCT LSB va danh gia capacity/PSNR.

## Tai va chay

```bash
imodule https://raw.githubusercontent.com/bac-ptit/labtainer/main/h264-iframe-scene-stego-hoangbac2004-imodule.tar
docker pull hoangbac2004/h264-iframe-scene-stego.students.student:latest
labtainer -r h264-iframe-scene-stego
```

## Lenh trong container

```bash
python3 step1_create_hardcut_video.py
python3 step2_detect_scene_cuts.py cover_h264.mp4
python3 step3_extract_iframe_targets.py cover_h264.mp4 scene_cuts.txt
python3 step4_embed_iframe_dct_lsb.py cover_h264.mp4 iframe_targets.txt message.txt
python3 step5_extract_iframe_payload.py stego_h264.mp4 embed_map.txt
python3 step6_evaluate_capacity_quality.py cover_h264.mp4 stego_h264.mp4
```

## Checkwork

- `create_cover_h264`
- `detect_hard_scene_cut`
- `extract_iframe_targets`
- `embed_dct_lsb_payload`
- `recover_iframe_message`
- `evaluate_capacity_quality`

Ket qua dung: `recovered_message.txt` chua `IFRAME_SCENE_H264_OK`.
