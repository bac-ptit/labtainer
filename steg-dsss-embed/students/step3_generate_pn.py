"""
Step 3: Sinh PN code (Pseudo-Noise) de trai pho.
Dung chung chuoi 8 chip voi lab steg-dsss-extract de hai lab tuong thich.
Output: pn_code.txt
"""
import numpy as np

# Cung chuoi voi lab steg-dsss-extract
pn_code = np.array([1, -1, 1, 1, -1, 1, -1, -1])

print("PN code length :", len(pn_code))
print("PN code        :", pn_code.tolist())

np.savetxt("pn_code.txt", pn_code, fmt='%d')
print("PN code saved to pn_code.txt")
