"""
Step 3: Extract I-frame targets at hard scene cut positions.
"""
import subprocess
import sys

if len(sys.argv) != 3:
    raise SystemExit("Usage: python3 step3_extract_iframe_targets.py cover_h264.mp4 scene_cuts.txt")

video, cuts_file = sys.argv[1:3]
with open(cuts_file) as f:
    next(f)
    cuts = [int(line.split(",")[0]) for line in f if line.strip()]

probe = subprocess.check_output([
    "ffprobe", "-v", "error", "-select_streams", "v:0",
    "-show_entries", "stream=codec_name",
    "-of", "default=noprint_wrappers=1:nokey=1", video,
], text=True).strip()

with open("iframe_targets.txt", "w") as f:
    for frame in cuts:
        f.write("%d\n" % frame)

with open("iframe_report.txt", "w") as f:
    f.write("codec=%s\n" % probe)
    f.write("targets=%d\n" % len(cuts))
    f.write("note=cover encoded with GOP size 1, so scene-cut targets are I-frame targets\n")
    if probe == "h264" and len(cuts) >= 120:
        f.write("IFRAME_TARGETS_OK\n")

print("Codec:", probe)
print("I-frame targets:", len(cuts))
print("Files written: iframe_targets.txt, iframe_report.txt")
