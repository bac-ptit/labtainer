"""
Step 6: Plot alpha sensitivity trade-offs.
Outputs:
  01_alpha_waveforms.png
  02_alpha_distortion.png
  03_alpha_correlation.png
  04_alpha_tradeoff.png
  plots_done.txt
"""
import csv
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import soundfile as sf

host, sr = sf.read("host.wav")
alpha_levels = np.loadtxt("alpha_levels.txt")
pn_code = np.loadtxt("pn_code.txt", dtype=int)
bits = np.loadtxt("message_bits.txt", dtype=int)
chips_per_bit = len(pn_code)
total_chips = len(bits) * chips_per_bit

extract_rows = []
with open("alpha_extraction_results.txt", newline="") as fh:
    for row in csv.DictReader(fh):
        extract_rows.append(row)

dist_rows = []
with open("alpha_distortion_metrics.txt", newline="") as fh:
    for row in csv.DictReader(fh):
        dist_rows.append(row)

alphas = np.array([float(r["alpha"]) for r in extract_rows])
bers = np.array([float(r["BER"]) for r in extract_rows])
mean_corr = np.array([float(r["MeanAbsCorrelation"]) for r in extract_rows])
rms_diff = np.array([float(r["RMS_Diff"]) for r in dist_rows])
snr_db = np.array([float(r["SNR_dB"]) for r in dist_rows])

N = 400
t = np.arange(N) / sr

plt.figure(figsize=(10, 5))
plt.plot(t, host[:N], label="host", color="black", linewidth=1.5)
for alpha in alpha_levels:
    stego, _ = sf.read("stego_alpha_%0.2f.wav" % float(alpha))
    plt.plot(t, stego[:N], label="alpha %.2f" % float(alpha), alpha=0.75)
plt.title("Host vs stego waveforms for different alpha levels")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig("01_alpha_waveforms.png", dpi=100)
plt.close()

plt.figure(figsize=(9, 5))
plt.plot(alphas, rms_diff, "o-", linewidth=2)
plt.title("Distortion increases with alpha")
plt.xlabel("Alpha")
plt.ylabel("RMS(host - stego)")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("02_alpha_distortion.png", dpi=100)
plt.close()

plt.figure(figsize=(9, 5))
plt.plot(alphas, mean_corr, "o-", color="tab:green", linewidth=2)
plt.title("Extraction margin increases with alpha")
plt.xlabel("Alpha")
plt.ylabel("Mean absolute DSSS correlation")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("03_alpha_correlation.png", dpi=100)
plt.close()

fig, ax1 = plt.subplots(figsize=(10, 5))
ax1.plot(alphas, mean_corr, "o-", color="tab:green", label="Mean |corr|")
ax1.set_xlabel("Alpha")
ax1.set_ylabel("Mean |corr|", color="tab:green")
ax1.tick_params(axis="y", labelcolor="tab:green")
ax1.grid(True, alpha=0.3)

ax2 = ax1.twinx()
ax2.plot(alphas, rms_diff, "s--", color="tab:red", label="RMS distortion")
ax2.set_ylabel("RMS distortion", color="tab:red")
ax2.tick_params(axis="y", labelcolor="tab:red")

plt.title("DSSS alpha trade-off: easier extraction vs higher distortion")
fig.tight_layout()
plt.savefig("04_alpha_tradeoff.png", dpi=100)
plt.close()

print("All 4 alpha plots generated:")
for name in ("01_alpha_waveforms.png", "02_alpha_distortion.png",
             "03_alpha_correlation.png", "04_alpha_tradeoff.png"):
    print(" -", name)

with open("plots_done.txt", "w") as fh:
    fh.write("ALPHA_PLOTS_OK\n")
print("plots_done.txt written.")
