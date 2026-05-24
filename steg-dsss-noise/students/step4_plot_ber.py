"""
Step 4: Ve bieu do BER vs SNR va cac bieu do phan tich khang nhieu.
Output:
  01_ber_vs_snr.png        - BER theo muc SNR
  02_signal_comparison.png - So sanh stego goc vs noisy (SNR thap nhat)
  03_spectrum_noisy.png    - Pho FFT stego vs noisy
  04_correlation_map.png   - Correlation values tai moi bit cho tung SNR
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import soundfile as sf

# === Doc du lieu ===
pn_code       = np.loadtxt("pn_code.txt", dtype=int)
original_bits = np.loadtxt("message_bits.txt", dtype=int)
host, sr      = sf.read("host.wav")
stego, _      = sf.read("stego.wav")
snr_levels    = np.loadtxt("snr_levels.txt", dtype=int)

chips_per_bit = len(pn_code)
num_bits      = len(original_bits)
total_chips   = num_bits * chips_per_bit

# Doc extraction_results.txt
data = np.genfromtxt("extraction_results.txt", delimiter=',', skip_header=1,
                     dtype=None, encoding='utf-8')
snrs = np.array([row[0] for row in data])
bers = np.array([row[1] for row in data])

# ============ 01. BER vs SNR ============
plt.figure(figsize=(10, 5))
plt.semilogy(snrs, np.clip(bers, 1e-4, 1), 'bo-', linewidth=2, markersize=8)
plt.axhline(y=0.0, color='green', linestyle='--', alpha=0.5, label='BER = 0 (perfect)')
plt.xlabel("SNR (dB)")
plt.ylabel("Bit Error Rate (BER)")
plt.title("DSSS Noise Robustness: BER vs SNR\n(Message='HELLO', PN=8 chips, alpha=0.05)")
plt.grid(True, which="both", alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig("01_ber_vs_snr.png", dpi=100)
plt.close()

# ============ 02. Signal Comparison ============
# Lay file noisy co SNR thap nhat
worst_snr = int(snr_levels[-1])
noisy_worst, _ = sf.read("noisy_snr%ddB.wav" % worst_snr)

N_PLOT = 400
t = np.arange(N_PLOT) / sr
fig, axes = plt.subplots(3, 1, figsize=(10, 8), sharex=True)

axes[0].plot(t, host[:N_PLOT], color='tab:blue')
axes[0].set_title("Host signal (original sine 440 Hz)")
axes[0].set_ylabel("Amplitude")
axes[0].grid(True)

axes[1].plot(t, stego[:N_PLOT], color='tab:orange')
axes[1].set_title("Stego signal (after DSSS embedding)")
axes[1].set_ylabel("Amplitude")
axes[1].grid(True)

axes[2].plot(t, noisy_worst[:N_PLOT], color='tab:red')
axes[2].set_title("Noisy stego (SNR = %d dB)" % worst_snr)
axes[2].set_ylabel("Amplitude")
axes[2].set_xlabel("Time (s)")
axes[2].grid(True)

plt.tight_layout()
plt.savefig("02_signal_comparison.png", dpi=100)
plt.close()

# ============ 03. Spectrum Comparison ============
def fft_db(x, sr):
    X = np.fft.rfft(x)
    freq = np.fft.rfftfreq(len(x), d=1.0/sr)
    mag = 20 * np.log10(np.abs(X) + 1e-12)
    return freq, mag

f1, m1 = fft_db(stego, sr)
f2, m2 = fft_db(noisy_worst, sr)

plt.figure(figsize=(10, 5))
plt.plot(f1, m1, label="Stego (clean)", color='tab:orange', alpha=0.8)
plt.plot(f2, m2, label="Noisy (SNR=%d dB)" % worst_snr, color='tab:red', alpha=0.6)
plt.title("Spectrum: Stego vs Noisy signal")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.xlim(0, 3000)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("03_spectrum_noisy.png", dpi=100)
plt.close()

# ============ 04. Correlation Map ============
def get_correlations(received, host_sig, pn, n_bits, cps):
    watermark = received[:n_bits*cps] - host_sig[:n_bits*cps]
    corrs = np.zeros(n_bits)
    for i in range(n_bits):
        block = watermark[i*cps:(i+1)*cps]
        corrs[i] = np.dot(block, pn)
    return corrs

fig, ax = plt.subplots(figsize=(12, 6))
colors = plt.cm.viridis(np.linspace(0, 1, len(snr_levels)))

for idx, snr in enumerate(snr_levels):
    noisy, _ = sf.read("noisy_snr%ddB.wav" % snr)
    corrs = get_correlations(noisy, host, pn_code, num_bits, chips_per_bit)
    ax.plot(range(num_bits), corrs, 'o-', color=colors[idx],
            label="SNR=%d dB" % snr, alpha=0.7, markersize=3)

ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel("Bit index")
ax.set_ylabel("Correlation value")
ax.set_title("Correlation values per bit at different SNR levels\n(Positive = bit 1, Negative = bit 0)")
ax.legend(loc='upper right', fontsize=8)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("04_correlation_map.png", dpi=100)
plt.close()

print("All 4 plots generated:")
for name in ("01_ber_vs_snr.png", "02_signal_comparison.png",
             "03_spectrum_noisy.png", "04_correlation_map.png"):
    print(" -", name)

# Flag cho pregrade
with open("plots_done.txt", "w") as f:
    f.write("ALL_PLOTS_OK\n")
print("plots_done.txt written.")
