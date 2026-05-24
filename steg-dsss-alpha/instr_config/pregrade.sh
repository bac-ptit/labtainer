#!/bin/bash
#
# pregrade.sh - steg-dsss-alpha
#
homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0

CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

# 1. Host + message + PN inputs
if [ -f host.wav ] && file host.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f message_bits.txt ] && [ "$(wc -l < message_bits.txt)" -ge 40 ] && \
   [ -f pn_code.txt ] && [ "$(wc -l < pn_code.txt)" -ge 8 ]; then
    echo "PREPARE_INPUTS_OK" >> "$CHECK_FILE"
fi

# 2. DSSS chip sequence
if [ -f chip_sequence.txt ] && [ "$(wc -l < chip_sequence.txt)" -ge 320 ]; then
    echo "CHIP_SEQUENCE_OK" >> "$CHECK_FILE"
fi

# 3. Four alpha stego files
alpha_wavs=$(ls stego_alpha_*.wav 2>/dev/null | wc -l)
if [ -f alpha_levels.txt ] && [ "$alpha_wavs" -ge 4 ] && \
   [ -f stego_alpha_0.01.wav ] && file stego_alpha_0.01.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f stego_alpha_0.03.wav ] && file stego_alpha_0.03.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f stego_alpha_0.05.wav ] && file stego_alpha_0.05.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f stego_alpha_0.10.wav ] && file stego_alpha_0.10.wav 2>/dev/null | grep -qi 'WAVE audio'; then
    echo "EMBED_ALPHA_OK" >> "$CHECK_FILE"
fi

# 4. Extraction results for all alpha levels
if [ -f alpha_extraction_results.txt ] && \
   [ "$(wc -l < alpha_extraction_results.txt)" -ge 5 ] && \
   grep -q '^0.01,' alpha_extraction_results.txt && \
   grep -q '^0.10,' alpha_extraction_results.txt; then
    echo "EXTRACT_ALPHA_OK" >> "$CHECK_FILE"
fi

# 5. Distortion metrics for all alpha levels
if [ -f alpha_distortion_metrics.txt ] && \
   [ "$(wc -l < alpha_distortion_metrics.txt)" -ge 5 ] && \
   grep -q '^0.01,' alpha_distortion_metrics.txt && \
   grep -q '^0.10,' alpha_distortion_metrics.txt; then
    echo "MEASURE_DISTORTION_OK" >> "$CHECK_FILE"
fi

# 6. Four plots + flag
if [ -f plots_done.txt ] && \
   [ -f 01_alpha_waveforms.png ] && \
   [ -f 02_alpha_distortion.png ] && \
   [ -f 03_alpha_correlation.png ] && \
   [ -f 04_alpha_tradeoff.png ]; then
    echo "PLOT_TRADEOFF_OK" >> "$CHECK_FILE"
fi
