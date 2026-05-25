#!/bin/bash
#
# pregrade.sh - steg-dsss-detect
#

homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0

CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

# 1. Test audio data
if [ -f host.wav ] && file host.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f clean_test.wav ] && file clean_test.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f stego_test.wav ] && file stego_test.wav 2>/dev/null | grep -qi 'WAVE audio'; then
    echo "AUDIO_OK" >> "$CHECK_FILE"
fi

# 2. DSSS signature
if [ -f pn_code.txt ] && [ "$(wc -l < pn_code.txt)" -ge 16 ] && \
   [ -f message_bits.txt ] && [ "$(wc -l < message_bits.txt)" -ge 48 ] && \
   [ -f chip_sequence.txt ] && [ "$(wc -l < chip_sequence.txt)" -ge 768 ]; then
    echo "SIGNATURE_OK" >> "$CHECK_FILE"
fi

# 3. Detector report
if [ -f detection_scores.txt ] && [ -f detection_report.txt ] && \
   grep -q '^clean_test.wav,CLEAN' detection_report.txt && \
   grep -q '^stego_test.wav,WATERMARK_PRESENT' detection_report.txt; then
    echo "DETECT_OK" >> "$CHECK_FILE"
fi

# 4. Detection plots
if [ -f plots_done.txt ] && \
   [ -f 01_test_audio_waveforms.png ] && \
   [ -f 02_dsss_signature.png ] && \
   [ -f 03_detection_scores.png ] && \
   [ -f 04_correlation_traces.png ]; then
    echo "PLOTS_OK" >> "$CHECK_FILE"
fi

# 5. Student summary
if [ -f student_summary.txt ] && \
   grep -q 'stego_test.wav' student_summary.txt && \
   grep -q 'WATERMARK_PRESENT' student_summary.txt && \
   grep -q 'clean_test.wav' student_summary.txt; then
    echo "SUMMARY_OK" >> "$CHECK_FILE"
fi
