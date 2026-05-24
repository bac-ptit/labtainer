"""
Step 4: Extract the message from every alpha-level stego file.
Output:
  alpha_extraction_results.txt
"""
import numpy as np
import soundfile as sf

host, _ = sf.read("host.wav")
pn_code = np.loadtxt("pn_code.txt", dtype=int)
original_bits = np.loadtxt("message_bits.txt", dtype=int)
alpha_levels = np.loadtxt("alpha_levels.txt")

chips_per_bit = len(pn_code)
total_chips = len(original_bits) * chips_per_bit

def extract_bits(stego):
    watermark = stego[:total_chips] - host[:total_chips]
    out = np.zeros(len(original_bits), dtype=int)
    correlations = np.zeros(len(original_bits), dtype=float)
    for i in range(len(original_bits)):
        block = watermark[i * chips_per_bit:(i + 1) * chips_per_bit]
        corr = float(np.dot(block, pn_code))
        correlations[i] = corr
        out[i] = 1 if corr > 0 else 0
    return out, correlations

def bits_to_string(bits):
    chars = []
    for i in range(0, len(bits), 8):
        byte = bits[i:i + 8]
        if len(byte) == 8:
            value = int("".join(str(int(b)) for b in byte), 2)
            chars.append(chr(value) if 32 <= value <= 126 else "?")
    return "".join(chars)

print("DSSS Alpha Extraction Results")
print("=" * 72)
print("Original message:", bits_to_string(original_bits))
print("%-8s | %-10s | %-8s | %-12s | %s" %
      ("Alpha", "BER", "Errors", "Mean |corr|", "Extracted"))
print("-" * 72)

rows = []
for alpha in np.atleast_1d(alpha_levels):
    filename = "stego_alpha_%0.2f.wav" % float(alpha)
    stego, _ = sf.read(filename)
    extracted, correlations = extract_bits(stego)
    errors = int(np.sum(extracted != original_bits))
    ber = errors / len(original_bits)
    mean_abs_corr = float(np.mean(np.abs(correlations)))
    msg = bits_to_string(extracted)
    rows.append((float(alpha), ber, errors, mean_abs_corr, msg))
    print("%-8.2f | %-10.4f | %4d/%-3d | %-12.6f | %s" %
          (float(alpha), ber, errors, len(original_bits), mean_abs_corr, msg))

with open("alpha_extraction_results.txt", "w") as fh:
    fh.write("alpha,BER,Errors,MeanAbsCorrelation,Extracted_Message\n")
    for alpha, ber, errors, mean_abs_corr, msg in rows:
        fh.write("%.2f,%.6f,%d,%.8f,%s\n" %
                 (alpha, ber, errors, mean_abs_corr, msg))

print("=" * 72)
print("Results saved to alpha_extraction_results.txt")
