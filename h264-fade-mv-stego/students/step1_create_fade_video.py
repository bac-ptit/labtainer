"""
Step 1: Create a synthetic fade/dissolve H.264 video.
"""
import os
import shutil
import subprocess

WIDTH = 160
HEIGHT = 90
FRAMES = 150
FPS = 12


def run(cmd):
    subprocess.run(cmd, check=True)


def scene_a(x, y, frame):
    return (30 + x + frame) % 256, (70 + y * 2) % 256, 210


def scene_b(x, y, frame):
    return 220, (35 + x * 2) % 256, (40 + y + frame) % 256


if os.path.isdir("fade_frames"):
    shutil.rmtree("fade_frames")
os.makedirs("fade_frames")

for i in range(FRAMES):
    alpha = i / float(FRAMES - 1)
    square_x = 12 + (i % 40)
    square_y = 20 + ((i * 2) % 28)
    with open("fade_frames/frame_%04d.ppm" % i, "wb") as f:
        f.write(("P6\n%d %d\n255\n" % (WIDTH, HEIGHT)).encode("ascii"))
        data = bytearray()
        for y in range(HEIGHT):
            for x in range(WIDTH):
                a = scene_a(x, y, i)
                b = scene_b(x, y, i)
                rgb = [int((1.0 - alpha) * a[c] + alpha * b[c]) for c in range(3)]
                if square_x <= x < square_x + 18 and square_y <= y < square_y + 14:
                    rgb = [255 - v for v in rgb]
                data.extend(rgb)
        f.write(data)

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-framerate", str(FPS), "-i", "fade_frames/frame_%04d.ppm",
    "-c:v", "libx264", "-preset", "ultrafast", "-crf", "0",
    "-pix_fmt", "yuv444p", "fade_h264.mp4",
])
with open("fade_metadata.txt", "w") as f:
    subprocess.run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=codec_name,width,height,avg_frame_rate",
        "-of", "default=noprint_wrappers=1", "fade_h264.mp4",
    ], check=True, stdout=f)

print("Created fade/dissolve video: fade_h264.mp4")
print("Frames:", FRAMES)
print("Metadata written: fade_metadata.txt")
