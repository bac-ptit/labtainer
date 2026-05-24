"""
Step 3: Embed the same DSSS chip sequence with multiple alpha values.
Outputs:
  stego_alpha_0.01.wav
  stego_alpha_0.03.wav
  stego_alpha_0.05.wav
  stego_alpha_0.10.wav
  alpha_levels.txt
"""
import numpy as np
import soundfile as sf

ALPHA_LEVELS = [0.01, 0.03, 0.05, 0.10]

host, sr = sf.read("host.wav")
chips = np.loadtxt("chip_sequence.txt", dtype=int).astype(float)

if len(chips) > len(host):
    raise SystemExit("Chip sequence is longer than host signal")

print("Embedding DSSS watermark at multiple alpha levels")
print("Host samples :", len(host))
print("Chip samples :", len(chips))
print("-" * 54)

for alpha in ALPHA_LEVELS:
    stego = host.copy()
    stego[:len(chips)] = host[:len(chips)] + alpha * chips
    filename = "stego_alpha_%0.2f.wav" % alpha
    sf.write(filename, stego, sr)
    print("alpha = %0.2f -> %s" % (alpha, filename))

np.savetxt("alpha_levels.txt", ALPHA_LEVELS, fmt="%.2f")
print("-" * 54)
print("Alpha levels saved to alpha_levels.txt")
print("Total stego files:", len(ALPHA_LEVELS))
