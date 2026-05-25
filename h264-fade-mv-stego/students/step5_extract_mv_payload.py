"""
Step 5: Extract the MV LSB payload from the H.264 stego video.
"""
import csv
import os
import shutil
import subprocess
import sys

BLOCK = 10
THRESHOLD = 128.0


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file")
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported max value")
        return width, height, f.read()


def block_mean(width, data, mb_x, mb_y):
    total = 0
    count = 0
    for y in range(mb_y * BLOCK, mb_y * BLOCK + 6):
        for x in range(mb_x * BLOCK, mb_x * BLOCK + 6):
            off = (y * width + x) * 3
            total += data[off] + data[off + 1] + data[off + 2]
            count += 3
    return total / float(count)


if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step5_extract_mv_payload.py stego_fade_h264.mp4 mv_embed_map.txt")

if os.path.isdir("decoded_stego_fade"):
    shutil.rmtree("decoded_stego_fade")
os.makedirs("decoded_stego_fade")
subprocess.run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", sys.argv[1], "decoded_stego_fade/frame_%04d.ppm"], check=True)

bits = []
with open(sys.argv[2], newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        frame = int(row["frame"]) + 1
        mb_x = int(row["mb_x"])
        mb_y = int(row["mb_y"])
        width, height, data = read_ppm("decoded_stego_fade/frame_%04d.ppm" % frame)
        bits.append("1" if block_mean(width, data, mb_x, mb_y) >= THRESHOLD else "0")

message = "".join(chr(int("".join(bits[i:i + 8]), 2)) for i in range(0, len(bits), 8) if len(bits[i:i + 8]) == 8)
with open("recovered_bits.txt", "w") as f:
    f.write("\n".join(bits) + "\n")
with open("recovered_message.txt", "w") as f:
    f.write(message + "\n")

print("Recovered bits:", len(bits))
print("Recovered message:", message)
