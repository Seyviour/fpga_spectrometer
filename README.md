This is an implementation of an audio spectrometer targetting the GW1NR-9 on the Tang Nano 9K.


## Hardware and Configuration
_________________


## Required Hardware

1. i2S microphone, or any other device that can generate an i2s signal (like a microcontroller). For this project, I used the INMP 441, but any other i2s compliant device should work, with only a small amount of modification needed (if any at all).
2. Tang Nano 9K: This board contains the GW1NR-9 FPGA that this project targets, as well as an HDMI port for sending out the generated video signal.


## Configuration
Working with a Tang Nano 9k, you'll only need to connect the three pins necessary to acquire i2s signals.
1. SCK (serial clock out) - pin
2. SD (Serial data in) - pin
3. WS (word select in) - pin

If you are using an INMP 441, you'll need to tie its L/R input to ground so that it outputs its signal in the left channel of the i2s frame. 

## Implementation Details
_________________________

## AUDIO ACQUISITION
The INMP441 microphone that this project uses generates 24-bit audio that we downsample to 8-bits. While the downstream modules are capable of handling 24-bit audio just fine, I had to downsample to fit the constraints of the GW1NR-9. Later parts of this documentatino should make my rationale for downsampling clearer. I wrote a simple i2s module[Link] to receive audio.

Please note that the receiver accepts single-channel audio on the **left** frame of an i2s signal. Here's a link to the specification of the INMP441, which I used as a reference to write the i2s receiver [link]

## FOURIER TRANSFORM
Computing a Fourier transform is necessary for determining the magnitude associated with the frequency components of the input sound signal. For this implementation, I found that the Sliding DFT is uniquely suited to the real-time nature of a spectrometer. The following section contains some more detail on the implementation of the SDFT.

### SDFT
An important property of the SDFT is that it is a recursive algorithm. What this means in practice, is that computing the Fourier transform of any one audio frame takes very little computation. While it is cumulatively less efficient than the FFT, the recursive property is great for real time applications. Mathematically, the SDFT is described as: 



The implementation of the SDFT here assumes an initial 'zero' signal so there's no need to compute an initial FFT. To support the implementation, we only need to maintain a ROM of twiddle factors (these are pregenerated with this script), and a working RAM that points to the current FFT. All computations are done in fixed point arithmetic.

## DISPLAY

This project sends (640 x 360) resolution DVI over the HDMI port of the Tang Nano 9K. Each pixel is 24-bit RGB. As color is only used to indicate intensity at the different frequency component, I opted to use only the red-channel of the DVI signal, and sending `0` on the Green and Blue channels. This helps us save on memory quite a bit.

To support drawing the FFTs over time, this implementation maintains a small display buffer




