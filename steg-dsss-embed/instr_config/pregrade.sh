#!/bin/bash
#
# pregrade.sh - steg-dsss-embed
#
# Kiem tra artifact ma student da sinh ra. Neu artifact ton tai
# voi noi dung dung, tuc la student da chay script tuong ung.
# Ghi flag *_OK vao check_artifacts.txt - de results.config +
# goals.config bat duoc.
#
# Tham so:
#   $1 = home directory cua student (vd: /home/ubuntu)
#   $2 = thu muc dich chua artifact (thuong rong)

homedir=$1
destdir=$2
cd "$homedir/$destdir" || exit 0

CHECK_FILE="$homedir/$destdir/check_artifacts.txt"
: > "$CHECK_FILE"

# 1. Tao host.wav (sine 440 Hz)
if [ -f host.wav ] && \
   file host.wav 2>/dev/null | grep -qi 'WAVE audio'; then
    echo "HOST_OK" >> "$CHECK_FILE"
fi

# 2. Ma hoa "HELLO" thanh 40 bit
if [ -f message_bits.txt ] && \
   [ "$(wc -l < message_bits.txt)" -ge 40 ]; then
    echo "BITS_OK" >> "$CHECK_FILE"
fi

# 3. Sinh PN code 8 chip
if [ -f pn_code.txt ] && \
   [ "$(wc -l < pn_code.txt)" -ge 8 ]; then
    echo "PN_OK" >> "$CHECK_FILE"
fi

# 4. Trai pho DSSS thanh 320 chip
if [ -f chip_sequence.txt ] && \
   [ "$(wc -l < chip_sequence.txt)" -ge 320 ]; then
    echo "CHIPS_OK" >> "$CHECK_FILE"
fi

# 5. Tao stego.wav
if [ -f stego.wav ] && \
   file stego.wav 2>/dev/null | grep -qi 'WAVE audio'; then
    echo "STEGO_OK" >> "$CHECK_FILE"
fi

# 6. Ve du 6 file PNG + plots_done.txt
if [ -f plots_done.txt ] && \
   [ -f 01_host_sine.png ] && \
   [ -f 02_pn_sequence.png ] && \
   [ -f 03_message_bits.png ] && \
   [ -f 04_chip_sequence.png ] && \
   [ -f 05_stego_vs_host.png ] && \
   [ -f 06_spectrum.png ]; then
    echo "PLOTS_OK" >> "$CHECK_FILE"
fi
