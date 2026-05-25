"""
Step 4: Embed message bits into selected I-frame targets.
"""
import os
import shutil
import subprocess
import sys

PATCH_X = 12
PATCH_Y = 10
PATCH_SIZE = 8
BIT_ZERO = 24
BIT_ONE = 232


def run(cmd):
    subprocess.run(cmd, check=True)


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file: %s" % path)
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported PPM max value")
        return width, height, bytearray(f.read())


def write_ppm(path, width, height, data):
    with open(path, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (width, height)).encode("ascii"))
        f.write(data)


def set_checker_patch(width, data, bit):
    base = BIT_ONE if bit == "1" else BIT_ZERO
    alt = max(0, min(255, base + (15 if bit == "0" else -15)))
    for y in range(PATCH_Y, PATCH_Y + PATCH_SIZE):
        for x in range(PATCH_X, PATCH_X + PATCH_SIZE):
            value = base if (x + y) % 2 == 0 else alt
            off = (y * width + x) * 3
            data[off] = value
            data[off + 1] = value
            data[off + 2] = value


if len(sys.argv) != 4:
    raise SystemExit("Usage: python3 step4_embed_iframe_dct_lsb.py cover_h264.mp4 iframe_targets.txt message.txt")

cover_video, targets_file, message_file = sys.argv[1:4]
with open(targets_file) as f:
    targets = [int(line.strip()) for line in f if line.strip()]
with open(message_file) as f:
    message = f.read().strip()
bits = [bit for ch in message for bit in format(ord(ch), "08b")]
if len(targets) < len(bits):
    raise SystemExit("Not enough I-frame targets for payload")

if os.path.isdir("stego_frames"):
    shutil.rmtree("stego_frames")
os.makedirs("stego_frames")
run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", cover_video, "stego_frames/frame_%04d.ppm"])

with open("embed_map.txt", "w") as m:
    m.write("bit_index,frame,bit\n")
    for index, bit in enumerate(bits):
        frame_number = targets[index] + 1
        path = "stego_frames/frame_%04d.ppm" % frame_number
        width, height, data = read_ppm(path)
        set_checker_patch(width, data, bit)
        write_ppm(path, width, height, data)
        m.write("%d,%d,%s\n" % (index, targets[index], bit))

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", "12", "-i", "stego_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-g", "1", "-pix_fmt", "yuv444p", "stego_h264.mp4",
])
with open("stego_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "stego_h264.mp4",
    ], check=True, stdout=f)

print("Payload bits embedded:", len(bits))
print("Stego video: stego_h264.mp4")
print("Files written: embed_map.txt, stego_metadata.txt")
