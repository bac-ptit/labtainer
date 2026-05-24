"""
Step 3: Trich xuat (extract) message tu cac file noisy bang DSSS despreading.
Tinh BER (Bit Error Rate) cho moi muc SNR.
Output: extraction_results.txt
"""
import numpy as np
import soundfile as sf

# Doc thong tin goc
pn_code       = np.loadtxt("pn_code.txt", dtype=int)
original_bits = np.loadtxt("message_bits.txt", dtype=int)
host, sr      = sf.read("host.wav")
snr_levels    = np.loadtxt("snr_levels.txt", dtype=int)

chips_per_bit = len(pn_code)
num_bits      = len(original_bits)
total_chips   = num_bits * chips_per_bit

def extract_bits(received, host_signal, pn, n_bits, cps):
    """
    Trich xuat bits tu tin hieu received bang DSSS despreading.
    1. Tru host de lay watermark signal
    2. Chia thanh tung block = chips_per_bit mau
    3. Tinh correlation voi PN code
    4. Quyet dinh bit: correlation > 0 -> 1, nguoc lai -> 0
    """
    # Tru host de lay phan watermark
    watermark = received[:total_chips] - host_signal[:total_chips]

    extracted = np.zeros(n_bits, dtype=int)
    for i in range(n_bits):
        block = watermark[i*cps:(i+1)*cps]
        correlation = np.dot(block, pn)
        extracted[i] = 1 if correlation > 0 else 0

    return extracted

def bits_to_string(bits_array):
    """Chuyen chuoi bit thanh ky tu ASCII."""
    chars = []
    for i in range(0, len(bits_array), 8):
        byte = bits_array[i:i+8]
        if len(byte) == 8:
            val = int(''.join(str(b) for b in byte), 2)
            if 32 <= val <= 126:
                chars.append(chr(val))
            else:
                chars.append('?')
    return ''.join(chars)

def calc_ber(original, extracted):
    """Tinh Bit Error Rate."""
    errors = np.sum(original != extracted)
    return errors / len(original)

# === Trich xuat tu tung file noisy ===
print("DSSS Extraction Results - Noise Robustness Test")
print("=" * 60)
print("Original message: %s (%d bits)" % (bits_to_string(original_bits), num_bits))
print("PN code length  : %d chips" % chips_per_bit)
print("=" * 60)
print()
print("%-8s | %-10s | %-8s | %s" % ("SNR(dB)", "BER", "Errors", "Extracted"))
print("-" * 60)

results = []

for snr in snr_levels:
    filename = "noisy_snr%ddB.wav" % snr
    noisy, _ = sf.read(filename)

    extracted = extract_bits(noisy, host, pn_code, num_bits, chips_per_bit)
    ber = calc_ber(original_bits, extracted)
    errors = int(np.sum(original_bits != extracted))
    msg = bits_to_string(extracted)

    print("%5d dB | %8.4f   | %4d/%2d  | \"%s\"" % (snr, ber, errors, num_bits, msg))
    results.append((snr, ber, errors, msg))

# Luu ket qua
with open("extraction_results.txt", "w") as f:
    f.write("SNR_dB,BER,Errors,Extracted_Message\n")
    for snr, ber, errors, msg in results:
        f.write("%d,%.6f,%d,%s\n" % (snr, ber, errors, msg))

print()
print("Results saved to extraction_results.txt")

# Nhan xet
print()
print("=" * 60)
print("NHAN XET:")
zero_ber = [r for r in results if r[1] == 0.0]
if zero_ber:
    print("- DSSS khang nhieu tot o SNR >= %d dB (BER = 0)" % min(r[0] for r in zero_ber))
high_ber = [r for r in results if r[1] > 0.1]
if high_ber:
    print("- Bat dau loi nhieu o SNR <= %d dB (BER > 10%%)" % max(r[0] for r in high_ber))
print("- Processing gain (PG) = %d chips/bit = %.1f dB" % (
    chips_per_bit, 10*np.log10(chips_per_bit)))
