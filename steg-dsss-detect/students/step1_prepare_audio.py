"""
Step 1: Prepare clean and watermarked test audio for DSSS detection.

Outputs:
  host.wav
  clean_test.wav
  stego_test.wav
"""
import numpy as np
import soundfile as sf

SAMPLE_RATE = 16000
DURATION = 5.0
FREQ_1 = 440.0
FREQ_2 = 660.0
AMPLITUDE = 0.35

rng = np.random.default_rng(2026)
t = np.linspace(0, DURATION, int(SAMPLE_RATE * DURATION), endpoint=False)

host = (
    AMPLITUDE * np.sin(2 * np.pi * FREQ_1 * t)
    + 0.15 * np.sin(2 * np.pi * FREQ_2 * t)
)
host = host + 0.01 * rng.normal(0.0, 1.0, len(host))
host = np.clip(host, -0.95, 0.95)

# clean_test.wav is an innocent version with a tiny independent noise floor.
clean_test = host + 0.004 * rng.normal(0.0, 1.0, len(host))
clean_test = np.clip(clean_test, -0.95, 0.95)

# stego_test.wav is initialized here. Step 2 creates the DSSS signature and
# step 3 will detect it; this hidden reference keeps the exercise reproducible.
sf.write("host.wav", host, SAMPLE_RATE)
sf.write("clean_test.wav", clean_test, SAMPLE_RATE)
sf.write("stego_test.wav", host, SAMPLE_RATE)

print("Sample rate :", SAMPLE_RATE)
print("Duration    :", DURATION, "s")
print("Host tones  :", FREQ_1, "Hz and", FREQ_2, "Hz")
print("Files written: host.wav, clean_test.wav, stego_test.wav")
