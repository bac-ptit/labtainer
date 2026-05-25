"""
Step 6: Verify H.264 codec and estimate distortion between cover and stego.

Usage:
  python3 step6_evaluate_h264_quality.py cover_h264.mp4 stego_h264.mp4

Outputs:
  quality_report.txt
  h264_report.txt
"""
import math
import os
import subprocess
import sys


def run_capture(cmd):
    return subprocess.check_output(cmd, text=True)


def read_ppm(path):
    with open(path, "rb") as f:
        magic = f.readline().strip()
        if magic != b"P6":
            raise SystemExit("Unsupported PPM file: %s" % path)
        width, height = [int(x) for x in f.readline().split()]
        maxval = int(f.readline())
        if maxval != 255:
            raise SystemExit("Unsupported maxval in %s" % path)
        return width, height, f.read()


def codec_name(path):
    return run_capture([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name",
        "-of", "default=noprint_wrappers=1:nokey=1", path,
    ]).strip()


def mse_between_frame_dirs(a_dir, b_dir):
    total = 0
    count = 0
    frames = sorted(name for name in os.listdir(a_dir) if name.endswith(".ppm"))
    for name in frames:
        a_path = os.path.join(a_dir, name)
        b_path = os.path.join(b_dir, name)
        if not os.path.exists(b_path):
            continue
        _, _, a = read_ppm(a_path)
        _, _, b = read_ppm(b_path)
        for x, y in zip(a, b):
            diff = x - y
            total += diff * diff
            count += 1
    return total / float(count)


if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step6_evaluate_h264_quality.py cover_h264.mp4 stego_h264.mp4")

cover, stego = sys.argv[1:3]
cover_codec = codec_name(cover)
stego_codec = codec_name(stego)

if not os.path.isdir("decoded_cover") or not os.path.isdir("decoded_stego"):
    raise SystemExit("Run step2 and step5 before quality evaluation")

mse = mse_between_frame_dirs("decoded_cover", "decoded_stego")
psnr = 99.0 if mse == 0 else 10.0 * math.log10((255.0 * 255.0) / mse)
cover_size = os.path.getsize(cover)
stego_size = os.path.getsize(stego)

with open("h264_report.txt", "w") as f:
    f.write("cover_codec=%s\n" % cover_codec)
    f.write("stego_codec=%s\n" % stego_codec)
    if cover_codec == "h264" and stego_codec == "h264":
        f.write("H264_OK\n")

with open("quality_report.txt", "w") as f:
    f.write("mse=%.6f\n" % mse)
    f.write("psnr=%.3f\n" % psnr)
    f.write("cover_size=%d\n" % cover_size)
    f.write("stego_size=%d\n" % stego_size)
    if psnr >= 25.0:
        f.write("PSNR_OK\n")

print("Cover codec:", cover_codec)
print("Stego codec:", stego_codec)
print("MSE: %.6f" % mse)
print("PSNR: %.3f dB" % psnr)
print("Files written: h264_report.txt, quality_report.txt")
