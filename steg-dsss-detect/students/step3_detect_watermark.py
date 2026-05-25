"""
Step 3: Detect which test audio contains the DSSS watermark.

Outputs:
  detection_scores.txt
  detection_report.txt
  correlation_clean_test.txt
  correlation_stego_test.txt
"""
import numpy as np
import soundfile as sf

TEST_FILES = ["clean_test.wav", "stego_test.wav"]
THRESHOLD = 0.4

host, sr = sf.read("host.wav")
chips = np.loadtxt("chip_sequence.txt", dtype=float)
signature_energy = float(np.dot(chips, chips))


def normalized_sliding_correlation(signal):
    residual = signal - host[:len(signal)]
    limit = len(residual) - len(chips) + 1
    if limit <= 0:
        raise SystemExit("Test signal is shorter than DSSS signature")

    scores = np.zeros(limit)
    for offset in range(limit):
        window = residual[offset:offset + len(chips)]
        scores[offset] = np.dot(window, chips) / np.sqrt(signature_energy)
    return scores


rows = []
for filename in TEST_FILES:
    audio, file_sr = sf.read(filename)
    if file_sr != sr:
        raise SystemExit("%s has unexpected sample rate" % filename)

    corr = normalized_sliding_correlation(audio)
    abs_corr = np.abs(corr)
    peak_index = int(np.argmax(abs_corr))
    peak_score = float(abs_corr[peak_index])
    label = "WATERMARK_PRESENT" if peak_score >= THRESHOLD else "CLEAN"

    np.savetxt("correlation_%s.txt" % filename.replace(".wav", ""), corr, fmt="%.8f")
    rows.append((filename, label, peak_score, peak_index))

with open("detection_scores.txt", "w") as f:
    f.write("file,peak_score,peak_offset,threshold\n")
    for filename, label, peak_score, peak_index in rows:
        f.write("%s,%.6f,%d,%.2f\n" % (filename, peak_score, peak_index, THRESHOLD))

with open("detection_report.txt", "w") as f:
    for filename, label, peak_score, peak_index in rows:
        f.write("%s,%s,score=%.6f,offset=%d\n" % (filename, label, peak_score, peak_index))

print("DSSS watermark detection")
print("Threshold:", THRESHOLD)
for filename, label, peak_score, peak_index in rows:
    print("%s -> %s (score %.3f at offset %d)" % (filename, label, peak_score, peak_index))
