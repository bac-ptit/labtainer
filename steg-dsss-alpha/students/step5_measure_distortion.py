"""
Step 5: Measure host/stego distortion for each alpha level.
Output:
  alpha_distortion_metrics.txt
"""
import numpy as np
import soundfile as sf

host, _ = sf.read("host.wav")
alpha_levels = np.loadtxt("alpha_levels.txt")

def rms(x):
    return float(np.sqrt(np.mean(np.square(x))))

host_rms = rms(host)

print("DSSS Alpha Distortion Metrics")
print("=" * 74)
print("%-8s | %-12s | %-12s | %-12s | %-10s" %
      ("Alpha", "RMS diff", "Peak diff", "SNR(dB)", "Detectable"))
print("-" * 74)

rows = []
for alpha in np.atleast_1d(alpha_levels):
    filename = "stego_alpha_%0.2f.wav" % float(alpha)
    stego, _ = sf.read(filename)
    diff = stego - host
    rms_diff = rms(diff)
    peak_diff = float(np.max(np.abs(diff)))
    snr_db = 20 * np.log10((host_rms + 1e-12) / (rms_diff + 1e-12))
    detectable = "LOW" if float(alpha) <= 0.03 else "HIGH"
    rows.append((float(alpha), rms_diff, peak_diff, snr_db, detectable))
    print("%-8.2f | %-12.8f | %-12.8f | %-12.4f | %-10s" %
          (float(alpha), rms_diff, peak_diff, snr_db, detectable))

with open("alpha_distortion_metrics.txt", "w") as fh:
    fh.write("alpha,RMS_Diff,Peak_Diff,SNR_dB,Detectability_Risk\n")
    for alpha, rms_diff, peak_diff, snr_db, detectable in rows:
        fh.write("%.2f,%.10f,%.10f,%.6f,%s\n" %
                 (alpha, rms_diff, peak_diff, snr_db, detectable))

print("=" * 74)
print("Metrics saved to alpha_distortion_metrics.txt")
print("Observation: alpha increases extraction margin and also increases distortion.")
