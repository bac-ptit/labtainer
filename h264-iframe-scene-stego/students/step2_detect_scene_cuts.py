"""
Step 2: Decode the H.264 video and detect hard scene cuts by frame difference.
"""
import os
import shutil
import subprocess
import sys

THRESHOLD = 28.0


def run(cmd):
    subprocess.run(cmd, check=True)


def read_ppm(path):
    with open(path, "rb") as f:
        if f.readline().strip() != b"P6":
            raise SystemExit("Not a PPM file: %s" % path)
        width, height = [int(v) for v in f.readline().split()]
        if int(f.readline()) != 255:
            raise SystemExit("Unsupported PPM max value")
        return width, height, f.read()


def mad(a, b):
    return sum(abs(x - y) for x, y in zip(a, b)) / float(len(a))


if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 step2_detect_scene_cuts.py cover_h264.mp4")

if os.path.isdir("decoded_cover"):
    shutil.rmtree("decoded_cover")
os.makedirs("decoded_cover")

run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", sys.argv[1], "decoded_cover/frame_%04d.ppm"])

frames = sorted(n for n in os.listdir("decoded_cover") if n.endswith(".ppm"))
cuts = []
previous = None
with open("scene_cuts.txt", "w") as out:
    out.write("frame,mean_abs_diff\n")
    for index, name in enumerate(frames):
        _, _, data = read_ppm(os.path.join("decoded_cover", name))
        if previous is not None:
            score = mad(previous, data)
            if score >= THRESHOLD:
                cuts.append(index)
                out.write("%d,%.3f\n" % (index, score))
        previous = data

print("Decoded frames:", len(frames))
print("Hard scene cuts detected:", len(cuts))
print("File written: scene_cuts.txt")
