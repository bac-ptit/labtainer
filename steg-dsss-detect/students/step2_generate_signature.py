"""
Step 2: Generate a DSSS signature and embed it into stego_test.wav.

Outputs:
  pn_code.txt
  message_bits.txt
  chip_sequence.txt
  stego_test.wav
"""
import numpy as np
import soundfile as sf

MESSAGE = "DETECT"
ALPHA = 0.035
OFFSET = 2400

pn_code = np.array([1, -1, 1, 1, -1, -1, 1, -1,
                    -1, 1, 1, -1, 1, -1, -1, 1], dtype=int)

bits = []
for ch in MESSAGE:
    bits.extend(int(b) for b in format(ord(ch), "08b"))
bits = np.array(bits, dtype=int)

chips = np.zeros(len(bits) * len(pn_code), dtype=int)
for i, bit in enumerate(bits):
    start = i * len(pn_code)
    chips[start:start + len(pn_code)] = pn_code if bit == 1 else -pn_code

host, sr = sf.read("host.wav")
if OFFSET + len(chips) > len(host):
    raise SystemExit("DSSS signature does not fit into host.wav")

stego = host.copy()
stego[OFFSET:OFFSET + len(chips)] = stego[OFFSET:OFFSET + len(chips)] + ALPHA * chips
stego = np.clip(stego, -0.95, 0.95)

np.savetxt("pn_code.txt", pn_code, fmt="%d")
np.savetxt("message_bits.txt", bits, fmt="%d")
np.savetxt("chip_sequence.txt", chips, fmt="%d")
sf.write("stego_test.wav", stego, sr)

with open("signature_params.txt", "w") as f:
    f.write("message=%s\n" % MESSAGE)
    f.write("alpha=%.3f\n" % ALPHA)
    f.write("offset=%d\n" % OFFSET)
    f.write("chips=%d\n" % len(chips))

print("Message       :", MESSAGE)
print("Bits          :", len(bits))
print("PN chips/bit  :", len(pn_code))
print("Signature len :", len(chips))
print("Embed offset  :", OFFSET)
print("Files written : pn_code.txt, message_bits.txt, chip_sequence.txt, stego_test.wav")
