# h264-fade-mv-stego

Lab Labtainer ve **giau tin vao Motion Vector trong doan fade/dissolve cua video H.264**. Lab tao video fade, phan tich vector chuyen dong cap block, loc MV co magnitude cao, nhung bit vao LSB cua MV va danh gia bitrate/statistics.

## Tai va chay

```bash
imodule https://raw.githubusercontent.com/bac-ptit/labtainer/main/h264-fade-mv-stego-hoangbac2004-imodule.tar
docker pull hoangbac2004/h264-fade-mv-stego.students.student:latest
labtainer -r h264-fade-mv-stego
```

## Lenh trong container

```bash
python3 step1_create_fade_video.py
python3 step2_analyze_motion_vectors.py fade_h264.mp4
python3 step3_filter_motion_vectors.py motion_vectors.csv
python3 step4_embed_mv_lsb.py fade_h264.mp4 selected_mvs.csv message.txt
python3 step5_extract_mv_payload.py stego_fade_h264.mp4 mv_embed_map.txt
python3 step6_evaluate_bitrate_stats.py fade_h264.mp4 stego_fade_h264.mp4
```

## Checkwork

- `create_fade_h264`
- `analyze_motion_vectors`
- `filter_high_motion_mvs`
- `embed_mv_lsb_payload`
- `recover_mv_message`
- `evaluate_bitrate_statistics`

Ket qua dung: `recovered_message.txt` chua `FADE_MV_H264_OK`.
