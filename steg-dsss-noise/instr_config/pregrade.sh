#!/bin/bash
#
# pregrade.sh - steg-dsss-noise
#
homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0

CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

# 1. stego.wav + host.wav + pn_code.txt + message_bits.txt
if [ -f stego.wav ] && file stego.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f host.wav ] && file host.wav 2>/dev/null | grep -qi 'WAVE audio' && \
   [ -f pn_code.txt ] && [ -f message_bits.txt ]; then
    echo "PREPARE_OK" >> "$CHECK_FILE"
fi

# 2. Noisy files (at least 4 files)
noisy_count=$(ls noisy_snr*dB.wav 2>/dev/null | wc -l)
if [ "$noisy_count" -ge 4 ] && [ -f snr_levels.txt ]; then
    echo "NOISE_OK" >> "$CHECK_FILE"
fi

# 3. extraction_results.txt with BER data
if [ -f extraction_results.txt ] && [ "$(wc -l < extraction_results.txt)" -ge 5 ]; then
    echo "EXTRACT_OK" >> "$CHECK_FILE"
fi

# 4. Plots
if [ -f plots_done.txt ] && \
   [ -f 01_ber_vs_snr.png ] && \
   [ -f 02_signal_comparison.png ] && \
   [ -f 03_spectrum_noisy.png ] && \
   [ -f 04_correlation_map.png ]; then
    echo "PLOTS_OK" >> "$CHECK_FILE"
fi
