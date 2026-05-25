"""
Step 5: Extract embedded bits from the H.264 stego video and rebuild the
message.

Usage:
  python3 step5_extract_scene_bits.py stego_h264.mp4 embed_map.txt

Outputs:
  decoded_stego/
  recovered_bits.txt
  recovered_message.txt
"""
import os
import shutil
import subprocess
import sys

PATCH_X = 8
PATCH_Y = 8
PATCH_SIZE = 10
THRESHOLD = 128.0


def run(cmd):
    subprocess.run(cmd, check=True)


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


def patch_mean(width, data):
    total = 0
    count = 0
    for y in range(PATCH_Y, PATCH_Y + PATCH_SIZE):
        for x in range(PATCH_X, PATCH_X + PATCH_SIZE):
            offset = (y * width + x) * 3
            total += data[offset] + data[offset + 1] + data[offset + 2]
            count += 3
    return total / float(count)


def bits_to_text(bits):
    chars = []
    for start in range(0, len(bits), 8):
        byte = bits[start:start + 8]
        if len(byte) == 8:
            chars.append(chr(int("".join(byte), 2)))
    return "".join(chars)


if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step5_extract_scene_bits.py stego_h264.mp4 embed_map.txt")

stego_video, embed_map_path = sys.argv[1:3]
if os.path.isdir("decoded_stego"):
    shutil.rmtree("decoded_stego")
os.makedirs("decoded_stego")

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-i", stego_video, "decoded_stego/frame_%04d.ppm",
])

frame_numbers = []
with open(embed_map_path) as f:
    next(f)
    for line in f:
        if line.strip():
            _, frame_index, _ = line.strip().split(",")
            frame_numbers.append(int(frame_index) + 1)

bits = []
for frame_number in frame_numbers:
    frame_path = os.path.join("decoded_stego", "frame_%04d.ppm" % frame_number)
    width, height, data = read_ppm(frame_path)
    bits.append("1" if patch_mean(width, data) >= THRESHOLD else "0")

message = bits_to_text(bits)

with open("recovered_bits.txt", "w") as f:
    for bit in bits:
        f.write("%s\n" % bit)

with open("recovered_message.txt", "w") as f:
    f.write(message + "\n")

print("Recovered bits:", len(bits))
print("Recovered message:", message)
print("Files written: recovered_bits.txt, recovered_message.txt")
