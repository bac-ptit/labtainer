"""
Step 4: Embed payload bits into selected MV LSBs and create a matching H.264 stego video.
"""
import csv
import os
import shutil
import subprocess
import sys

BLOCK = 10
BIT_ZERO = 28
BIT_ONE = 232


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file")
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported max value")
        return width, height, bytearray(f.read())


def write_ppm(path, width, height, data):
    with open(path, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (width, height)).encode("ascii"))
        f.write(data)


def set_block(width, data, mb_x, mb_y, bit):
    value = BIT_ONE if bit == "1" else BIT_ZERO
    start_x = mb_x * BLOCK
    start_y = mb_y * BLOCK
    for y in range(start_y, min(start_y + 6, start_y + BLOCK)):
        for x in range(start_x, min(start_x + 6, start_x + BLOCK)):
            off = (y * width + x) * 3
            data[off] = value
            data[off + 1] = value
            data[off + 2] = value


if len(sys.argv) != 4:
    raise SystemExit("Usage: python3 step4_embed_mv_lsb.py fade_h264.mp4 selected_mvs.csv message.txt")

video, selected_file, message_file = sys.argv[1:4]
message = open(message_file).read().strip()
bits = [bit for ch in message for bit in format(ord(ch), "08b")]
with open(selected_file, newline="") as f:
    rows = list(csv.DictReader(f))
if len(rows) < len(bits):
    raise SystemExit("Not enough selected MVs for payload")

if os.path.isdir("stego_fade_frames"):
    shutil.rmtree("stego_fade_frames")
os.makedirs("stego_fade_frames")
subprocess.run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", video, "stego_fade_frames/frame_%04d.ppm"], check=True)

with open("mv_embed_map.txt", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["bit_index", "frame", "mb_x", "mb_y", "original_mv_x", "embedded_mv_x", "bit"])
    for index, bit in enumerate(bits):
        row = rows[index]
        frame = int(row["frame"])
        mb_x = int(row["mb_x"])
        mb_y = int(row["mb_y"])
        original_mv_x = int(row["mv_x"])
        embedded_mv_x = original_mv_x if (original_mv_x & 1) == int(bit) else original_mv_x + 1
        path = "stego_fade_frames/frame_%04d.ppm" % (frame + 1)
        width, height, data = read_ppm(path)
        set_block(width, data, mb_x, mb_y, bit)
        write_ppm(path, width, height, data)
        writer.writerow([index, frame, mb_x, mb_y, original_mv_x, embedded_mv_x, bit])

subprocess.run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", "12", "-i", "stego_fade_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-pix_fmt", "yuv444p", "stego_fade_h264.mp4",
], check=True)
with open("stego_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "stego_fade_h264.mp4",
    ], check=True, stdout=f)

print("Payload bits embedded into MV LSB map:", len(bits))
print("Stego video: stego_fade_h264.mp4")
