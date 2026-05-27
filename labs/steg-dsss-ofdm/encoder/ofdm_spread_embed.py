# -*- coding: utf-8 -*-
import sys
import numpy as np
from scipy.io import wavfile

if len(sys.argv) != 5:
    print("Su dung: python3 ofdm_spread_embed.py cover_audio.wav <message> <seed> <alpha>")
    sys.exit(1)

input_file = sys.argv[1]
message = sys.argv[2]
seed = int(sys.argv[3])
alpha = float(sys.argv[4])

fs, cover_signal = wavfile.read(input_file)
if len(cover_signal.shape) > 1:
    cover_signal = cover_signal[:, 0]
cover = cover_signal.astype(np.float64)

N = len(cover)
num_subcarriers = 64
cp_len = 16
symbol_len = num_subcarriers + cp_len
num_symbols = N // symbol_len

bits = [int(b) for char in message for b in format(ord(char), '08b')]
bipolar = np.array(bits) * 2 - 1

np.random.seed(seed)
pn_seq = np.random.choice([-1, 1], size=len(bits))

spread_bits = bipolar * pn_seq

ofdm_grid = np.zeros((num_symbols, num_subcarriers), dtype=complex)
for i in range(min(len(spread_bits), num_symbols)):
    ofdm_grid[i, :] = spread_bits[i]

stego_signal = np.zeros(N, dtype=np.float64)
for i in range(num_symbols):
    freq_symbols = ofdm_grid[i, :]
    time_symbols = np.fft.ifft(freq_symbols).real
    cp = time_symbols[-cp_len:]
    ofdm_symbol = np.concatenate([cp, time_symbols])
    start = i * symbol_len
    end = start + symbol_len
    if end > N:
        break
    stego_signal[start:end] = cover[start:end] + alpha * ofdm_symbol * 32767

stego_signal = np.clip(stego_signal, -32768, 32767).astype(np.int16)
wavfile.write('stego_audio.wav', fs, stego_signal)

np.savez('ofdm_params.npz', num_subcarriers=num_subcarriers, cp_len=cp_len,
         seed=seed, num_bits=len(bits), num_symbols=num_symbols, N=N)

print(f"[+] Da nhung '{message}' vao OFDM + DSSS (seed={seed}, alpha={alpha})")
print(f"[+] So subcarriers={num_subcarriers}, CP={cp_len}, symbols={num_symbols}")
print(f"[+] Luu tai stego_audio.wav va ofdm_params.npz")
