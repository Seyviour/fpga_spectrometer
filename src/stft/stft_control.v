// THE STFT WILL OPERATE AS A STATE MACHINE
// WHEN THE I2S RECEIVER PULSES THAT IT HAS RECEIVED A NEW SAMPLE,
// THE STFT WILL ENTER ITS COMPUTE STATE
// SINCE THE SAMPLING CLOCK IS MUCH MUCH SLOWER THAN THE COMPUTE CLOCK,
// THE FFT WILL BE DONE COMPUTING BEFORE THE NEXT SAMPLE IS READY.

// THIS IS FREE RUNNING => IF THE I2S RECEIVER RESETS, IT TAKES THE TIME HIT
// BEFORE THE OUTPUT ON THE SCREEN IS VALID AGAIN


// 

module STFT_CONTROL #(
    parameter
    word_width = 16,
    FFT_SIZE = 256
) (
    input wire clk,  //27Mhz
    input wire RESET, 
    input wire SAMPLE_VALID, // from i2s clock domain 
    input wire signed [23:0] i_SAMPLE, // from i2s clock domain

    output reg signed [15:0] o_SAMPLE,
    output reg start_compute
);


// REGISTER SAMPLE

reg i_sample_valid, i_sample_valid_prev;


//sample_valid pulse when (i_sample_valid != i_sample_valid_prev) && i_sample_valid = 1;

always @(posedge clk) begin
    i_sample_valid <= SAMPLE_VALID;
    i_sample_valid_prev <= i_sample_valid;
    o_SAMPLE <= i_SAMPLE>>>16;
    if (RESET) begin
        i_sample_valid <= 0; 
        i_sample_valid_prev <= 0; 
    end
end

always @(*) begin
    start_compute = ((i_sample_valid != i_sample_valid_prev) && (i_sample_valid == 1'b1)) ? 1'b1: 1'b0;  
end





endmodule