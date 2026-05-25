"""
Step 4: Embed bits into small patches of frames selected after scene changes,
then encode the result as H.264.

Usage:
  python3 step4_embed_scene_bits.py cover_h264.mp4 selected_frames.txt message_bits.txt

Outputs:
  stego_frames/
  stego_h264.mp4
  stego_metadata.txt
  embed_map.txt
"""
import os
import shutil
import subprocess
import sys

PATCH_X = 8
PATCH_Y = 8
PATCH_SIZE = 10
BIT_ZERO = 18
BIT_ONE = 238


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
        return width, height, bytearray(f.read())


def write_ppm(path, width, height, data):
    with open(path, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (width, height)).encode("ascii"))
        f.write(data)


def set_patch(width, data, value):
    for y in range(PATCH_Y, PATCH_Y + PATCH_SIZE):
        for x in range(PATCH_X, PATCH_X + PATCH_SIZE):
            offset = (y * width + x) * 3
            data[offset] = value
            data[offset + 1] = value
            data[offset + 2] = value


if len(sys.argv) != 4:
    raise SystemExit("Usage: python3 step4_embed_scene_bits.py cover_h264.mp4 selected_frames.txt message_bits.txt")

cover_video, selected_path, bits_path = sys.argv[1:4]
with open(selected_path) as f:
    selected_frames = [int(line.strip()) for line in f if line.strip()]
with open(bits_path) as f:
    bits = [line.strip() for line in f if line.strip()]

if len(selected_frames) < len(bits):
    raise SystemExit("Not enough scene-change frames for message bits")

if os.path.isdir("stego_frames"):
    shutil.rmtree("stego_frames")
os.makedirs("stego_frames")

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-i", cover_video, "stego_frames/frame_%04d.ppm",
])

with open("embed_map.txt", "w") as embed_map:
    embed_map.write("bit_index,frame,bit\n")
    for bit_index, bit in enumerate(bits):
        frame_number = selected_frames[bit_index] + 1
        frame_path = os.path.join("stego_frames", "frame_%04d.ppm" % frame_number)
        width, height, data = read_ppm(frame_path)
        value = BIT_ONE if bit == "1" else BIT_ZERO
        set_patch(width, data, value)
        write_ppm(frame_path, width, height, data)
        embed_map.write("%d,%d,%s\n" % (bit_index, selected_frames[bit_index], bit))

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", "12", "-i", "stego_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-pix_fmt", "yuv444p", "stego_h264.mp4",
])

with open("stego_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "stego_h264.mp4",
    ], check=True, stdout=f)

print("Embedded bits:", len(bits))
print("Stego video: stego_h264.mp4")
print("Files written: embed_map.txt, stego_metadata.txt")
