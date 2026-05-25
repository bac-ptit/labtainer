"""
Step 1: Create a synthetic H.264 video with abrupt hard scene cuts.
"""
import os
import shutil
import subprocess

WIDTH = 160
HEIGHT = 90
FRAMES = 180
FPS = 12


def run(cmd):
    subprocess.run(cmd, check=True)


def pixel(frame, x, y):
    scene = frame % 3
    if scene == 0:
        return (30 + x * 2) % 256, (40 + y * 3) % 256, 210
    if scene == 1:
        return 220, (25 + x + frame) % 256, (35 + y * 2) % 256
    return (60 + y * 2) % 256, 210, (50 + x * 3) % 256


if os.path.isdir("cover_frames"):
    shutil.rmtree("cover_frames")
os.makedirs("cover_frames")

for i in range(FRAMES):
    with open("cover_frames/frame_%04d.ppm" % i, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (WIDTH, HEIGHT)).encode("ascii"))
        data = bytearray()
        for y in range(HEIGHT):
            for x in range(WIDTH):
                data.extend(pixel(i, x, y))
        f.write(data)

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", str(FPS), "-i", "cover_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-g", "1", "-pix_fmt", "yuv444p", "cover_h264.mp4",
])

with open("cover_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "cover_h264.mp4",
    ], check=True, stdout=f)

print("Created hard-cut cover video: cover_h264.mp4")
print("Frames:", FRAMES)
print("Codec metadata written to cover_metadata.txt")
