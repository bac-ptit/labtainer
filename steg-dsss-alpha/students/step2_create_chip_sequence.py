"""
Step 2: Spread message bits with the PN code.
Output:
  chip_sequence.txt
"""
import numpy as np

bits = np.loadtxt("message_bits.txt", dtype=int)
pn_code = np.loadtxt("pn_code.txt", dtype=int)

chips_per_bit = len(pn_code)
chip_sequence = np.zeros(len(bits) * chips_per_bit, dtype=int)

for i, bit in enumerate(bits):
    start = i * chips_per_bit
    end = start + chips_per_bit
    chip_sequence[start:end] = pn_code if bit == 1 else -pn_code

np.savetxt("chip_sequence.txt", chip_sequence, fmt="%d")

print("Input bits           :", len(bits))
print("Chips per bit        :", chips_per_bit)
print("Chip sequence length :", len(chip_sequence))
print("First 32 chips       :", chip_sequence[:32].tolist())
print("Chip sequence saved to chip_sequence.txt")
