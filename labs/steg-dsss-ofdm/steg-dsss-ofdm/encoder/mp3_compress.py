# -*- coding: utf-8 -*-
import os, sys

if len(sys.argv) != 3:
    print("Su dung: python3 mp3_compress.py <input.wav> <bitrate>")
    sys.exit(1)

input_file = sys.argv[1]
bitrate = sys.argv[2]
mp3_temp = "temp_channel.mp3"
output_file = "received_audio.wav"

print(f"[!] Dan nen file {input_file} xuong MP3 {bitrate} (mo phong kenh truyen)...")

if os.path.exists(mp3_temp): os.remove(mp3_temp)
if os.path.exists(output_file): os.remove(output_file)

cmd_compress = f"ffmpeg -i {input_file} -b:a {bitrate} {mp3_temp} -loglevel error"
if os.system(cmd_compress) != 0:
    print("[-] LOI: FFmpeg chua duoc cai dat. Chay: sudo apt install ffmpeg")
    sys.exit(1)

cmd_decompress = f"ffmpeg -i {mp3_temp} {output_file} -loglevel error"
os.system(cmd_decompress)

print(f"[+] Kenh truyen mo phong thanh cong! File: '{output_file}'")
