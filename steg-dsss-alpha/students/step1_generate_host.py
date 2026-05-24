"""
Step 1: Generate a clean host signal and shared DSSS inputs.
Outputs:
  host.wav
  message_bits.txt
  pn_code.txt
"""
import numpy as np
import soundfile as sf

SAMPLE_RATE = 16000
DURATION = 5.0
FREQ = 440.0
AMPLITUDE = 0.5
MESSAGE = "HELLO"
PN_CODE = np.array([1, -1, 1, 1, -1, 1, -1, -1], dtype=int)

t = np.linspace(0, DURATION, int(SAMPLE_RATE * DURATION), endpoint=False)
host = AMPLITUDE * np.sin(2 * np.pi * FREQ * t)
sf.write("host.wav", host, SAMPLE_RATE)

bits = []
for ch in MESSAGE:
    bits.extend(int(b) for b in format(ord(ch), "08b"))
bits = np.array(bits, dtype=int)

np.savetxt("message_bits.txt", bits, fmt="%d")
np.savetxt("pn_code.txt", PN_CODE, fmt="%d")

print("Message      :", MESSAGE)
print("Sample rate  :", SAMPLE_RATE)
print("Duration     :", DURATION, "s")
print("Host samples :", len(host))
print("Total bits   :", len(bits))
print("PN chips/bit :", len(PN_CODE))
print("Files created: host.wav, message_bits.txt, pn_code.txt")
