"""
Step 2: Them nhieu AWGN (Additive White Gaussian Noise) vao stego.wav
o nhieu muc SNR khac nhau.
Output: noisy_snr{X}dB.wav cho moi muc SNR
"""
import numpy as np
import soundfile as sf

# Doc stego signal
stego, sr = sf.read("stego.wav")

# Cac muc SNR can test (dB)
SNR_LEVELS = [50, 40, 30, 20, 15, 10, 5, 0]

def add_awgn(signal, snr_db):
    """Them nhieu Gaussian voi muc SNR cho truoc (dB)."""
    sig_power = np.mean(signal ** 2)
    noise_power = sig_power / (10 ** (snr_db / 10.0))
    noise = np.random.normal(0, np.sqrt(noise_power), len(signal))
    return signal + noise

print("Stego signal length:", len(stego), "samples")
print("Sample rate        :", sr, "Hz")
print()
print("Generating noisy versions:")
print("-" * 40)

for snr in SNR_LEVELS:
    noisy = add_awgn(stego, snr)
    filename = "noisy_snr%ddB.wav" % snr
    sf.write(filename, noisy, sr)
    print("  SNR = %3d dB  ->  %s" % (snr, filename))

# Luu danh sach SNR de cac step sau dung
np.savetxt("snr_levels.txt", SNR_LEVELS, fmt='%d')
print()
print("SNR levels saved to snr_levels.txt")
print("Total noisy files  :", len(SNR_LEVELS))
