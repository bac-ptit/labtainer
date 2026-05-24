"""
Step 6: Ve cac bieu do minh hoa qua trinh giau tin DSSS.
Sinh ra cac file PNG:
  01_host_sine.png       - Song sin host goc
  02_pn_sequence.png     - Chuoi PN code
  03_message_bits.png    - Bits cua thong diep
  04_chip_sequence.png   - Tin hieu sau khi trai pho
  05_stego_vs_host.png   - So sanh host vs stego (zoom in)
  06_spectrum.png        - Pho FFT cua host vs stego
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")          # khong can DISPLAY
import matplotlib.pyplot as plt
import soundfile as sf

# ============ DOC DU LIEU ============
host,  sr = sf.read("host.wav")
stego, _  = sf.read("stego.wav")
bits      = np.loadtxt("message_bits.txt",  dtype=int)
pn_code   = np.loadtxt("pn_code.txt",       dtype=int)
chips     = np.loadtxt("chip_sequence.txt", dtype=int)

# ============ 01. SONG SIN HOST ============
N_PLOT = 400  # ve 400 mau dau ~ 25 ms
t = np.arange(N_PLOT) / sr
plt.figure(figsize=(10, 3))
plt.plot(t, host[:N_PLOT], color="tab:blue")
plt.title("Step 1 - Host signal: sine wave 440 Hz")
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.grid(True)
plt.tight_layout()
plt.savefig("01_host_sine.png", dpi=100)
plt.close()

# ============ 02. PN CODE ============
plt.figure(figsize=(8, 3))
plt.stem(np.arange(len(pn_code)), pn_code, basefmt=" ")
plt.title("Step 3 - PN code (chip sequence)")
plt.xlabel("Chip index")
plt.ylabel("Value")
plt.ylim(-1.5, 1.5)
plt.grid(True)
plt.tight_layout()
plt.savefig("02_pn_sequence.png", dpi=100)
plt.close()

# ============ 03. MESSAGE BITS ============
plt.figure(figsize=(10, 3))
plt.step(np.arange(len(bits)), bits, where="post", color="tab:green")
plt.title("Step 2 - Message bits (HELLO = 40 bits)")
plt.xlabel("Bit index")
plt.ylabel("Bit value")
plt.ylim(-0.2, 1.2)
plt.grid(True)
plt.tight_layout()
plt.savefig("03_message_bits.png", dpi=100)
plt.close()

# ============ 04. CHIP SEQUENCE ============
plt.figure(figsize=(10, 3))
N_CHIPS = min(64, len(chips))
plt.step(np.arange(N_CHIPS), chips[:N_CHIPS], where="post", color="tab:red")
plt.title("Step 4 - Chip sequence after DSSS spreading (first %d chips)" % N_CHIPS)
plt.xlabel("Chip index")
plt.ylabel("Chip value")
plt.ylim(-1.5, 1.5)
plt.grid(True)
plt.tight_layout()
plt.savefig("04_chip_sequence.png", dpi=100)
plt.close()

# ============ 05. HOST vs STEGO ============
plt.figure(figsize=(10, 4))
plt.plot(t, host[:N_PLOT],  label="Host (original sine)",  color="tab:blue", alpha=0.8)
plt.plot(t, stego[:N_PLOT], label="Stego (after DSSS embed)", color="tab:orange", alpha=0.8)
plt.title("Step 5 - Host vs Stego signal (first %d samples)" % N_PLOT)
plt.xlabel("Time (s)")
plt.ylabel("Amplitude")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("05_stego_vs_host.png", dpi=100)
plt.close()

# ============ 06. SPECTRUM ============
def fft_db(x, sr):
    X    = np.fft.rfft(x)
    freq = np.fft.rfftfreq(len(x), d=1.0/sr)
    mag  = 20 * np.log10(np.abs(X) + 1e-12)
    return freq, mag

f1, m1 = fft_db(host,  sr)
f2, m2 = fft_db(stego, sr)
plt.figure(figsize=(10, 4))
plt.plot(f1, m1, label="Host spectrum",  color="tab:blue",   alpha=0.8)
plt.plot(f2, m2, label="Stego spectrum", color="tab:orange", alpha=0.7)
plt.title("Step 6 - Spectrum: host vs stego (DSSS spread the watermark)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.xlim(0, 2000)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("06_spectrum.png", dpi=100)
plt.close()

print("All 6 plots generated:")
for name in ("01_host_sine.png", "02_pn_sequence.png", "03_message_bits.png",
             "04_chip_sequence.png", "05_stego_vs_host.png", "06_spectrum.png"):
    print(" -", name)

# Tao file flag de pregrade kiem tra
with open("plots_done.txt", "w") as f:
    f.write("ALL_PLOTS_OK\n")
print("plots_done.txt written.")
