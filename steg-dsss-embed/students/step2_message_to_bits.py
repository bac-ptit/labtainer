"""
Step 2: Chuyen chuoi "HELLO" thanh chuoi bit (40 bit).
Output: message_bits.txt
"""
import numpy as np

MESSAGE = "HELLO"

bits = []
for ch in MESSAGE:
    binary = format(ord(ch), '08b')   # 8 bit cho moi ky tu
    for b in binary:
        bits.append(int(b))

bits = np.array(bits, dtype=int)

print("Message     :", MESSAGE)
print("Total bits  :", len(bits))
print("Bits        :", bits.tolist())

np.savetxt("message_bits.txt", bits, fmt='%d')
print("Bits saved to message_bits.txt")
