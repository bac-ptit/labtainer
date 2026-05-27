# -*- coding: utf-8 -*-
import sys
import numpy as np
from scipy.io import wavfile

if len(sys.argv) != 4:
    print("Su dung: python3 extract_despread.py received_audio.wav ofdm_params.npz cover_audio.wav")
    sys.exit(1)

_, rec_sig = wavfile.read(sys.argv[1])
rec = rec_sig.astype(np.float64)

params = np.load(sys.argv[2])
num_subcarriers = int(params['num_subcarriers'])
cp_len = int(params['cp_len'])
seed = int(params['seed'])
num_bits = int(params['num_bits'])
num_symbols = int(params['num_symbols'])
N = int(params['N'])

_, cov_sig = wavfile.read(sys.argv[3])
cover = cov_sig[:N].astype(np.float64)
rec = rec[:N]

diff = rec - cover

symbol_len = num_subcarriers + cp_len
recovered_symbols = np.zeros((num_symbols, num_subcarriers), dtype=complex)
for i in range(num_symbols):
    start = i * symbol_len + cp_len
    end = start + num_subcarriers
    if end > N:
        break
    ofdm_symbol = diff[start:end]
    recovered_symbols[i, :] = np.fft.fft(ofdm_symbol)

recovered_values = recovered_symbols[:num_bits, :].mean(axis=1).real

np.random.seed(seed)
pn_seq = np.random.choice([-1, 1], size=num_bits)

despread = recovered_values * pn_seq
recovered_bits = [1 if v > 0 else 0 for v in despread]

chars = []
for i in range(0, len(recovered_bits), 8):
    byte = recovered_bits[i:i+8]
    if len(byte) == 8:
        chars.append(chr(int("".join(map(str, byte)), 2)))

print(f"[+] Bit khoi phuc: {recovered_bits}")
print(f"[+] THONG DIEP GOC: '{''.join(chars)}'")
