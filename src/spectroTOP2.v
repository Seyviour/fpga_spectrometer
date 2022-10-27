module spectroTOP2 #(
    parameter
    FFT_SIZE=256,
    RAM_DEPTH=4096

) (
    input wire clk,
    input wire reset,

    input wire SD,
    input wire WS,

    output wire SCK,

    output wire [3:0] hdmi_tx_n,
    output wire [3:0] hdmi_tx_p
);

localparam TWIDDLE_FILE="/home/saviour/study/fpga_spectrogram/src/stft/factor.txt"; 
localparam MEM_FILE="/home/saviour/study/fpga_spectrogram/src/videogen/helpers/samplehex.txt";
localparam RAM_ADDR_WIDTH=$clog2(RAM_DEPTH);
localparam RAM_DATA_WIDTH=4;
localparam INPUT_WORD_WIDTH=16;
localparam NO_FFTS = 50;
localparam RAM_ADDRESS_WIDTH=12;
localparam COUNT_HIGH=4410;
localparam FFT_IDX_WIDTH=$clog2(NO_FFTS); 

wire hdmi_clk, hdmi_clk_5x, hdmi_clk_lock;


wire [RAM_ADDR_WIDTH-1:0] addr_rd, addr_wr;
wire [1:0] bank_rd, bank_wr;
wire [RAM_DATA_WIDTH-1:0] data_rd, data_wr; 
wire wr_en; 
wire [FFT_IDX_WIDTH-1:0] OLDEST_FFT_IDX; 


inputAndProcessing #(.TWIDDLE_FILE(TWIDDLE_FILE ),.WORD_WIDTH(INPUT_WORD_WIDTH ),
  .FFT_SIZE(FFT_SIZE ), .NO_FFTS(NO_FFTS ), .RAM_ADDRESS_WIDTH(RAM_ADDRESS_WIDTH ),
  .COUNT_HIGH (COUNT_HIGH )) thisInputAndProcessing 
  (
    .clk27 (clk),
    .reset (~reset ),
    .SD (SD),
    .WS (WS),
    .SCK (SCK),
    .disp_wr_en (wr_en),
    .disp_bank_wr (bank_wr),
    .disp_wr_address (addr_wr),
    .disp_data_wr (data_wr),
    .OLDEST_FFT_IDX  ( OLDEST_FFT_IDX)
);



bankRAM #(.NO_BANKS(2),.DATA_WIDTH(RAM_DATA_WIDTH),.DEPTH(RAM_DEPTH),.MEM_FILE (MEM_FILE)) thisBankRAM 
    (   
        .clk_wr (clk), // 27 MHz
        .clk_rd (hdmi_clk ),
        .wr_bank_select (bank_wr),
        .wr_en (wr_en),
        .addr_wr (addr_wr),
        .addr_rd (addr_rd),
        .data_wr (data_wr),
        .data_rd (data_rd),
        .rd_bank_select (bank_rd)
    );


hdmi_clock_gen this_hdmi_clock_gen 
    (
        .clk (clk ),
        .hdmi_clk_5x (hdmi_clk_5x),
        .hdmi_clk  (hdmi_clk),
        .hdmi_clk_lock(hdmi_clk_lock)
    );

wire [2:0] hve;
wire [23:0] rgb;


displaySystem #(.FFT_SIZE(FFT_SIZE ), .DATA_WIDTH (RAM_DATA_WIDTH )) thisDisplaySystem 
    (
        .hdmi_clk (hdmi_clk),
        .hdmi_clk_lock (hdmi_clk_lock),
        .reset (~reset),
        .data_rd (data_rd),
        .OLDEST_FFT_IDX (OLDEST_FFT_IDX),
        .bank_rd (bank_rd),
        .addr_rd (addr_rd),
        .rgb (rgb),
        .hve (hve)
    );

hdmi2 this_hdmi 
    (
        .reset((~hdmi_clk_lock | ~reset)),
        .hdmi_clk(hdmi_clk),
        .hdmi_clk_5x(hdmi_clk_5x),
        .hve_sync(hve),
        .rgb(rgb),
        .hdmi_tx_n (hdmi_tx_n),
        .hdmi_tx_p (hdmi_tx_p)
    );
endmodule