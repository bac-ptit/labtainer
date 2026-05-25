#!/bin/bash
homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0
CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

if [ -f fade_h264.mp4 ] && [ -f fade_metadata.txt ] && grep -q 'codec_name=h264' fade_metadata.txt; then
    echo "COVER_OK" >> "$CHECK_FILE"
fi
if [ -f motion_vectors.csv ] && [ "$(wc -l < motion_vectors.csv)" -ge 200 ]; then
    echo "MV_OK" >> "$CHECK_FILE"
fi
if [ -f selected_mvs.csv ] && [ -f mv_filter_report.txt ] && [ "$(wc -l < selected_mvs.csv)" -ge 120 ] && grep -q 'FILTER_OK' mv_filter_report.txt; then
    echo "FILTER_OK" >> "$CHECK_FILE"
fi
if [ -f stego_fade_h264.mp4 ] && [ -f mv_embed_map.txt ] && [ -f stego_metadata.txt ] && grep -q 'codec_name=h264' stego_metadata.txt && [ "$(wc -l < mv_embed_map.txt)" -ge 120 ]; then
    echo "EMBED_OK" >> "$CHECK_FILE"
fi
if [ -f recovered_message.txt ] && grep -q 'FADE_MV_H264_OK' recovered_message.txt; then
    echo "EXTRACT_OK" >> "$CHECK_FILE"
fi
if [ -f bitrate_report.txt ] && [ -f statistics_report.txt ] && grep -q 'BITRATE_OK' bitrate_report.txt && grep -q 'STATISTICS_OK' statistics_report.txt; then
    echo "STATS_OK" >> "$CHECK_FILE"
fi
