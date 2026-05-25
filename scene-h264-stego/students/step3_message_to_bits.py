"""
Step 3: Convert the secret message to bits.

Usage:
  python3 step3_message_to_bits.py message.txt

Outputs:
  message_bits.txt
  message_length.txt
"""
import sys

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 step3_message_to_bits.py message.txt")

with open(sys.argv[1], "r", encoding="utf-8") as f:
    message = f.read().strip()

bits = []
for ch in message:
    bits.extend(format(ord(ch), "08b"))

with open("message_bits.txt", "w") as f:
    for bit in bits:
        f.write("%s\n" % bit)

with open("message_length.txt", "w") as f:
    f.write("%d\n" % len(message))

print("Message:", message)
print("Characters:", len(message))
print("Bits:", len(bits))
print("Files written: message_bits.txt, message_length.txt")
