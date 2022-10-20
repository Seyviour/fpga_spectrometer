// `include "/home/saviour/study/fpga_spectrogram/src/videogen/pulse_detect_count.v"
// `include "/home/saviour/study/fpga_spectrogram/src/videogen/mag_and_log.v"
// `include "/home/saviour/study/fpga_spectrogram/src/videogen/idx_to_RAM.v"
module dispManager #(
    parameter
    COUNTHIGH = 4410,
    FFT_SIZE = 256,
    WORD_WIDTH = 16,
    NO_FFTS = 50,
    ADDRESS_WIDTH = 12,
    NO_BANKS = 2

) (
    input wire clk,
    input wire reset,
    input wire wr_en,
    input wire [$clog2(FFT_SIZE/2)-1:0] i_address,
    input wire [WORD_WIDTH*2-1:0] i_data,

    output reg signed [$clog2(NO_FFTS): 0] OLDEST_FFT_IDX, 
    output wire disp_wr_en,
    output wire [$clog2(WORD_WIDTH)-1: 0] wr_data,
    output reg [11:0] wr_address,
    output reg [NO_BANKS-1:0] bank_select
);


wire [$clog2(FFT_SIZE/2)-1:0] wr_idx;
wire pulse;

// wire disp_wr_en;
//1 CYCLE DELAY 
wire o_p_disp_wr_en;

assign disp_wr_en = o_p_disp_wr_en && (addr_R<FFT_SIZE/2);



pulseDetectCount #( .COUNTHIGH (COUNTHIGH )) thisPulseDetectCount 
    (
        .clk (clk),
        .reset (reset),
        .wr_en (wr_en),
        .disp_wr_en  (o_p_disp_wr_en),
        .pulse(pulse)
    );

//1 CYCLE DELAY
magnitudeAndLog #(.WORD_WIDTH (WORD_WIDTH )) thisMagnitudeAndLog 
    (
      .clk (clk),
      .Xk (i_data),
      .log (wr_data)
    );

reg [$clog2(FFT_SIZE/2)-1: 0] addr_R; 
// BUFFER WRITE ADDRESS TO MATCH DELAY

always @(posedge clk)
    addr_R <= i_address; 

assign wr_idx = addr_R;



// ** ASSUMING 50 FFTS (IDX 0 - 49)
// DRAW ORDER IS FROM LEAST RECENT TO MOST RECENT DFT
// WHEN OLDEST IS 49, 49 IS DRAWN FIRST AND 0 IS DRAWN LAST

// WHEN OLDEST IS 0, 0 IS DRAWN FIRST AND 49 IS DRAWN LAST
// AT RESET, 0 IS OLDEST AND 49 IS MOST RECENT

localparam FFT_IDX_WIDTH = $clog2(NO_FFTS);


always @(posedge clk) begin
    if ((OLDEST_FFT_IDX == NO_FFTS-1) | reset) begin
        OLDEST_FFT_IDX <= 0; 
    end else begin 
        if (pulse) 
            OLDEST_FFT_IDX <= OLDEST_FFT_IDX + 1'b1;
    end
end



idx2RAM #(.ADDRESS_WIDTH(ADDRESS_WIDTH),.NO_FFTS(NO_FFTS),.FFT_SIZE(FFT_SIZE),.NO_BANKS (NO_BANKS)) thisidx2RAM
   (
       .FFT_IDX (OLDEST_FFT_IDX), //write newest dft to location of oldest fft
       .sample_idx (wr_idx),
       .bank_select (bank_select),
       .wr_address  (wr_address)
   );

endmodule