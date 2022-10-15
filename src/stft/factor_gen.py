import numpy as np


if __name__ == "__main__":
    str_mag_format = "{:04x}"
    multiplier = 2 ** (16-1)-1 
    with open ("factor.txt", "w") as f:
        for x in range(512):
            factor = np.exp(-1j*2*np.pi*x/512) * multiplier
            real = int(factor.real) & (2**16)-1
            imag = int(factor.imag) & (2**16)-1

            real = str_mag_format.format(real)
            imag = str_mag_format.format(imag)

            f.write(real+imag+"\n")

