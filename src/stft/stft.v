module STFT #(
    parameter
    TWIDDLE_FILE = "/home/saviour/study/fpga_spectrogram/src/stft/factor.txt",
    WORD_WIDTH = 16,
    FFT_SIZE = 256
) (
    input wire clk,
    input wire SAMPLE_VALID, //FROM I2S RECEIVER 
    input wire signed [23: 0] SAMPLE, // FROM I2S RECEIVER
    input wire reset,

    output wire disp_wr_en,
    output wire [$clog2(FFT_SIZE)-1: 0] disp_wr_idx,
    output wire [WORD_WIDTH*2-1:0] disp_wr_data
);


wire [WORD_WIDTH-1:0] o_SAMPLE;
wire start_compute; 

//in an ideal world, I would isolate the path for the disp_wr_en signal
//it's too tightly coupled with the stft as is
//but that would mean having to handle buffers and delays explicitly
//Will try to decouple when logic is good

STFT_CONTROL  #(.word_width(16), .FFT_SIZE(FFT_SIZE)) this_stft_control
  (
    .clk(clk), //27Mhz
    .RESET(reset), 
    .SAMPLE_VALID(SAMPLE_VALID), // from i2s clock domain 
    .i_SAMPLE(SAMPLE), // from i2s clock domain

    .o_SAMPLE(o_SAMPLE),
    .start_compute(start_compute)
);

wire signed [15: 0] sample_diff;
wire sample_wr_en;
wire [$clog2(FFT_SIZE)-1: 0] oldest_sample_address;
wire [$clog2(FFT_SIZE)-1: 0] dft_idx;
wire dft_wr_en;
wire [WORD_WIDTH-1: 0] oldest_sample; 

wire disp_wr_en_sm; 
STFT_SM #(.WORD_WIDTH(16) ,.FFT_SIZE(FFT_SIZE)) this_stft_sm 
    (
        .clk(clk), 
        .reset(reset), 
        .start_compute(start_compute),
        .SAMPLE(o_SAMPLE),
        .OLDEST_SAMPLE(oldest_sample),
        
        .disp_wr_en(disp_wr_en_sm),
        .sample_diff(sample_diff),
        .sample_wr_en(sample_wr_en),
        .oldest_sample_address(oldest_sample_address), 
        .idx(dft_idx),  // TO TWIDDLE ADDRESS GENERATION UNIT
        .wr_en(dft_wr_en)
    );

iRAM #(.WORD_WIDTH(WORD_WIDTH), .ADDRESS_WIDTH($clog2(FFT_SIZE))) SAMPLE_RAM
    (
        .clk(clk),
        .wr_en(sample_wr_en),
        .wr_data(o_SAMPLE),
        .wr_addr(oldest_sample_address),
        .rd_addr(oldest_sample_address),
        .rd_data(oldest_sample)
    );

wire [WORD_WIDTH*2-1: 0] Xk_prev, Xk, twiddle;
wire o_dft_wr_en; 
wire [$clog2(FFT_SIZE)-1:0] o_dft_idx; 

twiddleROM #(.N(FFT_SIZE), .word_size(WORD_WIDTH ),.memory_file (TWIDDLE_FILE)) this_twiddleROM (
      .read_address (dft_idx ),
      .twiddle  ( twiddle)
    );

wire disp_wr_en_spu; 
SPU #(.WORD_WIDTH(WORD_WIDTH ),.FFT_SIZE (FFT_SIZE )) this_SPU (
      .clk(clk),
      .sample_diff (sample_diff ),
      .i_disp_wr_en(disp_wr_en_sm),
      .twiddle (twiddle ),
      .Xk_prev (Xk_prev ),
      .wr_en (dft_wr_en ),
      .o_wr_en (o_dft_wr_en ),
      .o_disp_wr_en(disp_wr_en_spu),

      .i_idx (dft_idx ),
      .Xk (Xk ),
      .o_idx  ( o_dft_idx)
      
    );

iRAM #(.WORD_WIDTH(2*WORD_WIDTH), .ADDRESS_WIDTH($clog2(FFT_SIZE))) FFT_RAM
    (
        .clk(clk),
        .wr_en(o_dft_wr_en),
        .wr_data(Xk),
        .wr_addr(o_dft_idx),
        .rd_addr(dft_idx),
        .rd_data(Xk_prev)
    );

   
assign disp_wr_en = disp_wr_en_spu; 
assign disp_wr_idx = o_dft_idx;
assign disp_wr_data = Xk; 


initial begin
    $dumpfile("stft.vcd");
    $dumpvars(0, STFT);
end


endmodule