"""
Step 5: Write a concise detection summary.

Output:
  student_summary.txt
"""

with open("detection_report.txt") as f:
    report_lines = [line.strip() for line in f if line.strip()]

with open("detection_scores.txt") as f:
    score_lines = [line.strip() for line in f if line.strip()]

with open("student_summary.txt", "w") as f:
    f.write("DSSS Watermark Detection Summary\n")
    f.write("================================\n")
    f.write("Method: sliding correlation between audio residual and DSSS chip signature.\n")
    f.write("Decision rule: peak score >= threshold means WATERMARK_PRESENT.\n\n")
    f.write("Scores:\n")
    for line in score_lines:
        f.write("  %s\n" % line)
    f.write("\nDecisions:\n")
    for line in report_lines:
        f.write("  %s\n" % line)

print("student_summary.txt written.")
for line in report_lines:
    print(line)
