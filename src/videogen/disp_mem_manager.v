// `include "/home/saviour/study/fpga_spectrogram/src/videogen/pulse_detect_count.v"
// `include "/home/saviour/study/fpga_spectrogram/src/videogen/mag_and_log.v"
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


// NEGATIVE INDEXING FOR OLDEST FFT_IDX
// RANGE IS (-49 TO 0) ALL INCLUSIVE
// STARTS WITH OLDEST AT -49
// NEWEST IS AT -49 + 49

always @(posedge clk) begin
    if (pulse)
        OLDEST_FFT_IDX <= OLDEST_FFT_IDX + 1'b1;
    if (OLDEST_FFT_IDX == 0)
        OLDEST_FFT_IDX <= -(NO_FFTS-1); 
    if (reset)
        OLDEST_FFT_IDX <= -(NO_FFTS-1);
end

localparam N_IDX_BITS = $clog2(NO_FFTS);

wire [$clog2(NO_FFTS)-1:0] NEWEST_FFT_IDX;
//reg [$clog2(NO_FFTS)-1:0]  CURR_FFT_IDX;

assign NEWEST_FFT_IDX = OLDEST_FFT_IDX + (N_IDX_BITS)'(NO_FFTS-1); 

//always @(*) begin
//    CURR_FFT_IDX = ((NEWEST_FFT_IDX+y[COORDW-1:3]) > (N_IDX_BITS-1)'(NO_FFTS-1))
//                    ? (NEWEST_FFT_IDX+y[COORDW-1:3]) - (N_IDX_BITS-1)'(NO_FFTS-1)
//                    :  (NEWEST_FFT_IDX+y[COORDW-1:3]);            
//end

//idx2RAM #(.ADDRESS_WIDTH(12),.NO_FFTS(50 ),.FFT_SIZE(256 ),.NO_BANKS (2 )) thisidx2RAM
//    (
//        .FFT_IDX (NEWEST_FFT_IDX),
//        .sample_idx (wr_idx),
//        .bank_select (bank_select),
//        .wr_address  (wr_address)
//    );

reg [11:0] offset; 
always @(*) begin
    case(NEWEST_FFT_IDX[N_IDX_BITS-1])
        1'b0: bank_select = 2'b01; 
        1'b1: bank_select = 2'b10;
        default: bank_select = 2'b00;
    endcase

    offset = {5'(NEWEST_FFT_IDX[N_IDX_BITS-2: 0]), 7'b0}; //128 LOCATIONS PER FFT
    wr_address = offset + wr_idx; 
end





endmodule