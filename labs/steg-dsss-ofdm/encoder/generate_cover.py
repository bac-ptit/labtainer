# -*- coding: utf-8 -*-
import os, sys
try:
    import numpy as np
    from scipy.io import wavfile
except ImportError:
    os.system("python3 -m pip install --index-url https://pypi.org/simple/ numpy scipy")
    os.execv(sys.executable, ['python3'] + sys.argv)

print("[!] Dang tao file am thanh cover_audio.wav (5 giay, 44100 Hz)...")
sample_rate = 44100
duration = 5.0
t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
signal = 0.5 * np.sin(2 * np.pi * 440 * t) + 0.3 * np.sin(2 * np.pi * 660 * t)
noise = np.random.normal(0, 0.05, signal.shape)
cover_audio = np.clip(signal + noise, -1.0, 1.0)
wavfile.write('cover_audio.wav', sample_rate, (cover_audio * 32767).astype(np.int16))
print("[+] Da tao 'cover_audio.wav' thanh cong!")
