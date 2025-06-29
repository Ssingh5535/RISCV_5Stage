# Read imem.hex and emit 32-bit-wide COE
hex_in  = '/home/Stephen/Desktop/imem.hex'
coe_out = '/home/Stephen/Desktop/imem.coe'

# load all instruction bytes as a flat list of 2-char hex tokens
tokens = []
with open(hex_in, 'r') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('@'):
            continue
        # remove spaces and split every two hex-chars
        line = line.replace(' ', '')
        tokens += [ line[i:i+2] for i in range(0, len(line), 2) ]

# group into 4-byte (8 hex-char) words
words = []
for i in range(0, len(tokens), 4):
    chunk = tokens[i:i+4]
    if len(chunk) < 4:
        # pad the last partial word with zeroes if necessary
        chunk += ['00'] * (4 - len(chunk))
    # little-endian vs big-endian depends on how your BRAM generator expects it— 
    # most RISC-V instr are little-endian, so reverse the byte order:
    word = ''.join(reversed(chunk))
    words.append(word)

# write out the COE
with open(coe_out, 'w') as f:
    f.write('memory_initialization_radix=16;\n')
    f.write('memory_initialization_vector=\n')
    for i, w in enumerate(words):
        sep = ',' if i < len(words)-1 else ';'
        f.write(f'{w}{sep}\n')

print("Wrote", len(words), "words to", coe_out)

