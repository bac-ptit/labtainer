"""
Step 4: Plot DSSS detection artifacts.

Outputs:
  01_test_audio_waveforms.png
  02_dsss_signature.png
  03_detection_scores.png
  04_correlation_traces.png
  plots_done.txt
"""
import csv
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import soundfile as sf

host, sr = sf.read("host.wav")
clean, _ = sf.read("clean_test.wav")
stego, _ = sf.read("stego_test.wav")
chips = np.loadtxt("chip_sequence.txt", dtype=int)
pn_code = np.loadtxt("pn_code.txt", dtype=int)
corr_clean = np.loadtxt("correlation_clean_test.txt")
corr_stego = np.loadtxt("correlation_stego_test.txt")

scores = []
with open("detection_scores.txt", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        scores.append((row["file"], float(row["peak_score"]), float(row["threshold"])))

N = 900
t = np.arange(N) / sr
plt.figure(figsize=(10, 4))
plt.plot(t, clean[:N], label="clean_test.wav", alpha=0.8)
plt.plot(t, stego[:N], label="stego_test.wav", alpha=0.8)
plt.title("Test audio waveforms")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("01_test_audio_waveforms.png", dpi=100)
plt.close()

plt.figure(figsize=(10, 4))
plt.subplot(2, 1, 1)
plt.stem(np.arange(len(pn_code)), pn_code, basefmt=" ")
plt.title("PN code")
plt.ylim(-1.5, 1.5)
plt.grid(True)
plt.subplot(2, 1, 2)
plt.step(np.arange(min(160, len(chips))), chips[:160], where="post", color="tab:red")
plt.title("DSSS chip signature (first 160 chips)")
plt.ylim(-1.5, 1.5)
plt.grid(True)
plt.tight_layout()
plt.savefig("02_dsss_signature.png", dpi=100)
plt.close()

labels = [item[0] for item in scores]
values = [item[1] for item in scores]
threshold = scores[0][2]
plt.figure(figsize=(8, 4))
bars = plt.bar(labels, values, color=["tab:blue", "tab:orange"])
plt.axhline(threshold, color="tab:red", linestyle="--", label="threshold")
plt.title("Detection peak scores")
plt.ylabel("Absolute correlation score")
plt.legend()
plt.grid(True, axis="y")
plt.tight_layout()
plt.savefig("03_detection_scores.png", dpi=100)
plt.close()

plt.figure(figsize=(10, 4))
plt.plot(np.abs(corr_clean), label="clean_test.wav")
plt.plot(np.abs(corr_stego), label="stego_test.wav")
plt.axhline(threshold, color="tab:red", linestyle="--", label="threshold")
plt.title("Sliding DSSS correlation traces")
plt.xlabel("Candidate offset (samples)")
plt.ylabel("Absolute normalized correlation")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("04_correlation_traces.png", dpi=100)
plt.close()

with open("plots_done.txt", "w") as f:
    f.write("DETECTION_PLOTS_OK\n")

print("Detection plots generated.")
