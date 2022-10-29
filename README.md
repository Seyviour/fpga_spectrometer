This is an (ongoing) implementation of an audio spectrometer targetting the GW1NR-9 on the Tang Nano 9K.


PROJECT DETAILS 
_________________

- Audio(8 bits) acquisition is over I2S. I'm working with the INMP441 but any compliant microphone should suffice. 

- The specific version of the Fourier transform used here is the STFT (256 samples); 

- Display is over the HDMI/DVI port on the Tang Nano 9K;


CURRENT STATE OF AFFAIRS
_________________________

With the simulated mic input, this is the displayed output:

![Unfinished spectrometer](doc/spectro.gif)




Next step is to hook the FPGA up to real mic input, write more tests, and more documentation.
