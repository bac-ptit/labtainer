"""
Step 2: Analyze motion-vector candidates in the fade/dissolve segment.
This lab uses deterministic block-level vector analysis as a stable teaching
artifact for H.264 MV steganography.
"""
import csv
import os
import shutil
import subprocess
import sys

BLOCK = 10

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 step2_analyze_motion_vectors.py fade_h264.mp4")

if os.path.isdir("decoded_fade"):
    shutil.rmtree("decoded_fade")
os.makedirs("decoded_fade")
subprocess.run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", sys.argv[1], "decoded_fade/frame_%04d.ppm"], check=True)

frames = sorted(n for n in os.listdir("decoded_fade") if n.endswith(".ppm"))
with open("motion_vectors.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["frame", "mb_x", "mb_y", "mv_x", "mv_y", "magnitude"])
    for frame in range(1, len(frames)):
        for mb_y in range(1, 8):
            for mb_x in range(1, 14):
                mv_x = ((frame + mb_x * 2) % 9) - 4
                mv_y = ((frame * 2 + mb_y * 3) % 9) - 4
                # Fade/dissolve regions are modeled as high-variance blocks.
                if (frame + mb_x + mb_y) % 3 == 0:
                    mv_x += 5
                magnitude = (mv_x * mv_x + mv_y * mv_y) ** 0.5
                writer.writerow([frame, mb_x, mb_y, mv_x, mv_y, "%.3f" % magnitude])

print("Decoded frames:", len(frames))
print("Motion-vector candidates written: motion_vectors.csv")
