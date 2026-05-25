#!/bin/bash
homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0
CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

if [ -f cover_h264.mp4 ] && [ -f cover_metadata.txt ] && grep -q 'codec_name=h264' cover_metadata.txt; then
    echo "COVER_OK" >> "$CHECK_FILE"
fi
if [ -f scene_cuts.txt ] && [ "$(wc -l < scene_cuts.txt)" -ge 120 ]; then
    echo "SCENE_OK" >> "$CHECK_FILE"
fi
if [ -f iframe_targets.txt ] && [ -f iframe_report.txt ] && [ "$(wc -l < iframe_targets.txt)" -ge 120 ] && grep -q 'IFRAME_TARGETS_OK' iframe_report.txt; then
    echo "IFRAME_OK" >> "$CHECK_FILE"
fi
if [ -f stego_h264.mp4 ] && [ -f embed_map.txt ] && [ -f stego_metadata.txt ] && grep -q 'codec_name=h264' stego_metadata.txt && [ "$(wc -l < embed_map.txt)" -ge 120 ]; then
    echo "EMBED_OK" >> "$CHECK_FILE"
fi
if [ -f recovered_message.txt ] && grep -q 'IFRAME_SCENE_H264_OK' recovered_message.txt; then
    echo "EXTRACT_OK" >> "$CHECK_FILE"
fi
if [ -f capacity_report.txt ] && [ -f quality_report.txt ] && grep -q 'CAPACITY_OK' capacity_report.txt && grep -q 'PSNR_OK' quality_report.txt; then
    echo "QUALITY_OK" >> "$CHECK_FILE"
fi
