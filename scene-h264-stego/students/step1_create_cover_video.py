"""
Step 1: Create a synthetic cover video with frequent scene changes and
encode it as H.264.

Outputs:
  cover_frames/
  cover_h264.mp4
  cover_metadata.txt
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


def pixel_for(frame_index, x, y):
    scene = frame_index % 2
    if scene == 0:
        r = (40 + x * 2 + frame_index) % 256
        g = (30 + y * 3) % 256
        b = 190
    else:
        r = 190
        g = (40 + x + frame_index * 2) % 256
        b = (30 + y * 2) % 256
    return r, g, b


if os.path.isdir("cover_frames"):
    shutil.rmtree("cover_frames")
os.makedirs("cover_frames")

for i in range(FRAMES):
    path = os.path.join("cover_frames", "frame_%04d.ppm" % i)
    with open(path, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (WIDTH, HEIGHT)).encode("ascii"))
        data = bytearray()
        for y in range(HEIGHT):
            for x in range(WIDTH):
                data.extend(pixel_for(i, x, y))
        f.write(data)

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", str(FPS), "-i", "cover_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-pix_fmt", "yuv444p", "cover_h264.mp4",
])

with open("cover_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "cover_h264.mp4",
    ], check=True, stdout=f)

print("Created cover_h264.mp4 with %d frames at %d fps" % (FRAMES, FPS))
print("Resolution: %dx%d" % (WIDTH, HEIGHT))
print("Metadata written to cover_metadata.txt")
