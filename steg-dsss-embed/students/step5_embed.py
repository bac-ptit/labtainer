"""
Step 5: Nhung chuoi chip vao song sin host de tao stego.wav.
Cong them alpha * chip vao tung mau dau cua host signal.
Output: stego.wav
"""
import numpy as np
import soundfile as sf

ALPHA = 0.05   # Cuong do nhung (cang nho cang kho phat hien bang tai)

# Doc tin hieu host
host, sr = sf.read("host.wav")

# Doc chuoi chip
chips = np.loadtxt("chip_sequence.txt", dtype=int).astype(float)

if len(chips) > len(host):
    raise SystemExit("Chip sequence dai hon host signal!")

# Tao tin hieu stego
stego = host.copy()
stego[:len(chips)] = host[:len(chips)] + ALPHA * chips

# Ghi ra file
sf.write("stego.wav", stego, sr)

print("Sample rate    :", sr)
print("Host length    :", len(host))
print("Chip length    :", len(chips))
print("Embed strength :", ALPHA)
print("Stego saved to stego.wav")
