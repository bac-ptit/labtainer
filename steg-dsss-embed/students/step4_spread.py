"""
Step 4: Trai pho DSSS - bien chuoi bit thanh chuoi chip.
Bit 1 -> giu nguyen PN code
Bit 0 -> dao dau PN code (-PN)
Output: chip_sequence.txt (do dai = num_bits * len(PN))
"""
import numpy as np

bits    = np.loadtxt("message_bits.txt", dtype=int)
pn_code = np.loadtxt("pn_code.txt",      dtype=int)

chips_per_bit = len(pn_code)
num_bits      = len(bits)

chip_sequence = np.zeros(num_bits * chips_per_bit, dtype=int)

for i, b in enumerate(bits):
    if b == 1:
        chip_sequence[i*chips_per_bit:(i+1)*chips_per_bit] =  pn_code
    else:
        chip_sequence[i*chips_per_bit:(i+1)*chips_per_bit] = -pn_code

print("Number of bits  :", num_bits)
print("Chips per bit   :", chips_per_bit)
print("Chip sequence length:", len(chip_sequence))
print("First 32 chips  :", chip_sequence[:32].tolist())

np.savetxt("chip_sequence.txt", chip_sequence, fmt='%d')
print("Chip sequence saved to chip_sequence.txt")
