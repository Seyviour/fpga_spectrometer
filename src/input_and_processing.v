
module inputAndProcessing #(
    parameter
    TWIDDLE_FILE = "stft/factor.txt",
    WORD_WIDTH = 16,
    FFT_SIZE = 256
) (
    input wire clk27,
    input wire reset, 
    input wire SD,
    input wire WS,

    output wire SCK,
    output wire disp_wr_en,
    output wire [$clog2(FFT_SIZE)-1:0] disp_wr_idx,
    output wire [WORD_WIDTH*2-1: 0] disp_wr_data

    
);

wire i2s_clk;

i2s_clk_gen this_i2s_clk_gen 
    (
        .reset(~reset),
        .clk_in (clk27),
        .i2s_clk  ( i2s_clk)
    );


wire [23: 0] SAMPLE;
wire SAMPLE_VALID; 

i2s_receiver this_i2s_receiver 
    (
        .i2s_clk (i2s_clk),
        .reset (reset),
        .SD (SD),
        .WS (WS),
        .SCK (SCK),
        .SAMPLE (SAMPLE),
        .SAMPLE_VALID (SAMPLE_VALID)
    );

STFT #(.TWIDDLE_FILE(TWIDDLE_FILE ), .WORD_WIDTH(WORD_WIDTH ), .FFT_SIZE (FFT_SIZE )) this_STFT 
    (
        .clk (clk27),
        .SAMPLE_VALID (SAMPLE_VALID),
        .SAMPLE (SAMPLE),
        .reset (reset),
        .disp_wr_en (disp_wr_en),
        .disp_wr_idx (disp_wr_idx),
        .disp_wr_data  (disp_wr_data)
    );



endmodule