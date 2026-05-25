"""
Step 6: Evaluate payload capacity and visual quality.
"""
import math
import os
import sys


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file: %s" % path)
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported PPM max value")
        return f.read()


if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step6_evaluate_capacity_quality.py cover_h264.mp4 stego_h264.mp4")

with open("embed_map.txt") as f:
    payload_bits = max(0, sum(1 for _ in f) - 1)
with open("iframe_targets.txt") as f:
    targets = sum(1 for line in f if line.strip())
capacity_bits = targets

total = 0
count = 0
for name in sorted(n for n in os.listdir("decoded_cover") if n.endswith(".ppm")):
    stego_path = os.path.join("decoded_stego", name)
    if not os.path.exists(stego_path):
        continue
    a = read_ppm(os.path.join("decoded_cover", name))
    b = read_ppm(stego_path)
    for x, y in zip(a, b):
        d = x - y
        total += d * d
        count += 1
mse = total / float(count)
psnr = 99.0 if mse == 0 else 10.0 * math.log10((255.0 * 255.0) / mse)

with open("capacity_report.txt", "w") as f:
    f.write("iframe_targets=%d\n" % targets)
    f.write("payload_bits=%d\n" % payload_bits)
    f.write("capacity_bits=%d\n" % capacity_bits)
    if capacity_bits >= payload_bits >= 120:
        f.write("CAPACITY_OK\n")
with open("quality_report.txt", "w") as f:
    f.write("mse=%.6f\n" % mse)
    f.write("psnr=%.3f\n" % psnr)
    f.write("cover_size=%d\n" % os.path.getsize(sys.argv[1]))
    f.write("stego_size=%d\n" % os.path.getsize(sys.argv[2]))
    if psnr >= 25.0:
        f.write("PSNR_OK\n")

print("Payload bits:", payload_bits)
print("I-frame capacity bits:", capacity_bits)
print("PSNR: %.3f dB" % psnr)
