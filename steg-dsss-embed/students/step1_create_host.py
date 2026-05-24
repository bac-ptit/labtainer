"""
Step 1: Tao tin hieu host la mot song sin.
Output: host.wav  (file am thanh song sin de giau tin vao do)
"""
import numpy as np
import soundfile as sf

# Thong so song sin
SAMPLE_RATE = 16000      # 16 kHz
DURATION    = 5.0        # 5 giay
FREQ        = 440.0      # 440 Hz (not La)
AMPLITUDE   = 0.5

# Tao truc thoi gian
t = np.linspace(0, DURATION, int(SAMPLE_RATE * DURATION), endpoint=False)

# Tao song sin
host = AMPLITUDE * np.sin(2 * np.pi * FREQ * t)

# Luu file
sf.write("host.wav", host, SAMPLE_RATE)

print("Sample Rate :", SAMPLE_RATE)
print("Duration    :", DURATION, "s")
print("Frequency   :", FREQ, "Hz")
print("Total samples:", len(host))
print("Host signal saved to host.wav")
