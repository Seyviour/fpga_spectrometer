module dispManager #(
    parameter
    COUNTHIGH = 4410,
    FFT_SIZE = 256,
    WORD_WIDTH = 16

) (
    input wire clk,
    input wire reset,
    input wire wr_en,
    input wire [$clog2(FFT_SIZE)-1:0] i_address,
    input wire [WORD_WIDTH*2-1:0] i_data,

    output wire disp_wr_en,
    output wire [$clog2(WORD_WIDTH)-1: 0] wr_data,
    output wire [$clog2(FFT_SIZE)-1:0] wr_idx
);
    

// wire disp_wr_en;
//1 CYCLE DELAY 
pulseDetectCount #( .COUNTHIGH (COUNTHIGH )) thisPulseDetectCount 
    (
        .clk (clk),
        .reset (reset),
        .wr_en (wr_en),
        .disp_wr_en  (disp_wr_en)
    );

//1 CYCLE DELAY
magnitudeAndLog #(.WORD_WIDTH (WORD_WIDTH )) thisMagnitudeAndLog 
    (
      .clk (clk),
      .Xk (i_data),
      .log (wr_data)
    );

reg [$clog2(FFT_SIZE)-1: 0] addr_R; 
// BUFFER WRITE ADDRESS TO MATCH DELAY
always @(posedge clk)
    addr_R <= i_address; 


assign wr_idx = addr_R; 



endmodule