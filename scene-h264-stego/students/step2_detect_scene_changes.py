"""
Step 2: Detect scene changes from the decoded H.264 video.

Usage:
  python3 step2_detect_scene_changes.py cover_h264.mp4

Outputs:
  decoded_cover/
  scene_changes.txt
  selected_frames.txt
"""
import os
import shutil
import subprocess
import sys

THRESHOLD = 35.0


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


def mean_abs_diff(a, b):
    total = 0
    for x, y in zip(a, b):
        total += abs(x - y)
    return total / float(len(a))


if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 step2_detect_scene_changes.py cover_h264.mp4")

video = sys.argv[1]
if os.path.isdir("decoded_cover"):
    shutil.rmtree("decoded_cover")
os.makedirs("decoded_cover")

run([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-i", video, "decoded_cover/frame_%04d.ppm",
])

frames = sorted(name for name in os.listdir("decoded_cover") if name.endswith(".ppm"))
selected = []
with open("scene_changes.txt", "w") as scene_file:
    scene_file.write("frame,mean_abs_diff\n")
    prev_data = None
    for index, name in enumerate(frames):
        _, _, data = read_ppm(os.path.join("decoded_cover", name))
        if prev_data is not None:
            score = mean_abs_diff(prev_data, data)
            if score >= THRESHOLD:
                selected.append(index)
                scene_file.write("%d,%.3f\n" % (index, score))
        prev_data = data

with open("selected_frames.txt", "w") as f:
    for frame_index in selected:
        f.write("%d\n" % frame_index)

print("Decoded frames:", len(frames))
print("Scene threshold:", THRESHOLD)
print("Selected scene-change frames:", len(selected))
print("Files written: scene_changes.txt, selected_frames.txt")
