#!/bin/bash
#
# pregrade.sh - scene-h264-stego
#

homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0

CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

if [ -f cover_h264.mp4 ] && [ -f cover_metadata.txt ] && \
   grep -q 'codec_name=h264' cover_metadata.txt; then
    echo "COVER_OK" >> "$CHECK_FILE"
fi

if [ -f scene_changes.txt ] && [ -f selected_frames.txt ] && \
   [ "$(wc -l < selected_frames.txt)" -ge 128 ]; then
    echo "SCENE_OK" >> "$CHECK_FILE"
fi

if [ -f message_bits.txt ] && [ -f message_length.txt ] && \
   [ "$(wc -l < message_bits.txt)" -ge 128 ]; then
    echo "BITS_OK" >> "$CHECK_FILE"
fi

if [ -f stego_h264.mp4 ] && [ -f embed_map.txt ] && [ -f stego_metadata.txt ] && \
   grep -q 'codec_name=h264' stego_metadata.txt && \
   [ "$(wc -l < embed_map.txt)" -ge 128 ]; then
    echo "EMBED_OK" >> "$CHECK_FILE"
fi

if [ -f recovered_message.txt ] && [ -f recovered_bits.txt ] && \
   grep -q 'SCENE_H264_STEGO_OK' recovered_message.txt; then
    echo "EXTRACT_OK" >> "$CHECK_FILE"
fi

if [ -f quality_report.txt ] && [ -f h264_report.txt ] && \
   grep -q 'H264_OK' h264_report.txt && \
   grep -q 'PSNR_OK' quality_report.txt; then
    echo "QUALITY_OK" >> "$CHECK_FILE"
fi
