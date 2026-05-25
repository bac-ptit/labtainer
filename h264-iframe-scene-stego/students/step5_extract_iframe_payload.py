"""
Step 5: Extract the I-frame scene-cut payload from the H.264 stego video.
"""
import os
import shutil
import subprocess
import sys

PATCH_X = 12
PATCH_Y = 10
PATCH_SIZE = 8
THRESHOLD = 128.0


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file: %s" % path)
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported PPM max value")
        return width, height, f.read()


def patch_mean(width, data):
    total = 0
    count = 0
    for y in range(PATCH_Y, PATCH_Y + PATCH_SIZE):
        for x in range(PATCH_X, PATCH_X + PATCH_SIZE):
            off = (y * width + x) * 3
            total += data[off] + data[off + 1] + data[off + 2]
            count += 3
    return total / float(count)


if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step5_extract_iframe_payload.py stego_h264.mp4 embed_map.txt")

if os.path.isdir("decoded_stego"):
    shutil.rmtree("decoded_stego")
os.makedirs("decoded_stego")
subprocess.run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", sys.argv[1], "decoded_stego/frame_%04d.ppm"], check=True)

frames = []
with open(sys.argv[2]) as f:
    next(f)
    for line in f:
        if line.strip():
            _, frame, _ = line.strip().split(",")
            frames.append(int(frame) + 1)

bits = []
for frame in frames:
    width, height, data = read_ppm("decoded_stego/frame_%04d.ppm" % frame)
    bits.append("1" if patch_mean(width, data) >= THRESHOLD else "0")

message = "".join(chr(int("".join(bits[i:i + 8]), 2)) for i in range(0, len(bits), 8) if len(bits[i:i + 8]) == 8)
with open("recovered_bits.txt", "w") as f:
    f.write("\n".join(bits) + "\n")
with open("recovered_message.txt", "w") as f:
    f.write(message + "\n")

print("Recovered bits:", len(bits))
print("Recovered message:", message)
