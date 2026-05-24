"""
Step 1: Tao tin hieu stego (giong lab steg-dsss-embed).
Nhung chuoi "HELLO" vao song sin host bang DSSS.
Output: stego.wav, host.wav, pn_code.txt, message_bits.txt
"""
import numpy as np
import soundfile as sf

# === Thong so ===
SAMPLE_RATE = 16000
DURATION    = 5.0
FREQ        = 440.0
AMPLITUDE   = 0.5
ALPHA       = 0.05
MESSAGE     = "HELLO"
PN_CODE     = np.array([1, -1, 1, 1, -1, 1, -1, -1])

# === Tao host signal ===
t = np.linspace(0, DURATION, int(SAMPLE_RATE * DURATION), endpoint=False)
host = AMPLITUDE * np.sin(2 * np.pi * FREQ * t)
sf.write("host.wav", host, SAMPLE_RATE)

# === Message -> bits ===
bits = []
for ch in MESSAGE:
    for b in format(ord(ch), '08b'):
        bits.append(int(b))
bits = np.array(bits, dtype=int)
np.savetxt("message_bits.txt", bits, fmt='%d')

# === Trai pho DSSS ===
chips_per_bit = len(PN_CODE)
chip_sequence = np.zeros(len(bits) * chips_per_bit, dtype=int)
for i, b in enumerate(bits):
    if b == 1:
        chip_sequence[i*chips_per_bit:(i+1)*chips_per_bit] = PN_CODE
    else:
        chip_sequence[i*chips_per_bit:(i+1)*chips_per_bit] = -PN_CODE

# === Nhung vao host ===
stego = host.copy()
stego[:len(chip_sequence)] += ALPHA * chip_sequence.astype(float)
sf.write("stego.wav", stego, SAMPLE_RATE)

# === Luu PN code ===
np.savetxt("pn_code.txt", PN_CODE, fmt='%d')

print("Message         :", MESSAGE)
print("Total bits      :", len(bits))
print("PN code length  :", len(PN_CODE))
print("Chip sequence   :", len(chip_sequence))
print("Embed strength  :", ALPHA)
print("Files created   : host.wav, stego.wav, pn_code.txt, message_bits.txt")
