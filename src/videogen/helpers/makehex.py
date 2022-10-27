from random import randint

hexformat = '{:X}'
with open("samplehex.txt", "w") as f:
    for x in range(32):
        for y in range(128):
            if (y == 0 or y == 127) or (x == 0 or x == 31):
                val = 15
            else:
                val = 0
            f.write(hexformat.format(val)+"\n")