"""
Step 3: Select high-motion vectors suitable for MV LSB embedding.
"""
import csv
import sys

THRESHOLD = 5.0

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 step3_filter_motion_vectors.py motion_vectors.csv")

selected = []
with open(sys.argv[1], newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        if float(row["magnitude"]) >= THRESHOLD and not (int(row["mv_x"]) == 0 and int(row["mv_y"]) == 0):
            selected.append(row)

with open("selected_mvs.csv", "w", newline="") as f:
    fieldnames = ["frame", "mb_x", "mb_y", "mv_x", "mv_y", "magnitude"]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for row in selected:
        writer.writerow(row)

with open("mv_filter_report.txt", "w") as f:
    f.write("threshold=%.2f\n" % THRESHOLD)
    f.write("selected=%d\n" % len(selected))
    if len(selected) >= 120:
        f.write("FILTER_OK\n")

print("Threshold:", THRESHOLD)
print("Selected high-motion MVs:", len(selected))
print("Files written: selected_mvs.csv, mv_filter_report.txt")
