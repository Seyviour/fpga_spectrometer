module i2s_receiver (
    input wire i2s_clk,
    input wire reset, 
    input wire SD, //i2s serial data line
    input wire WS, //i2s l/r select 
    output wire SCK, //i2s clock passthrough output
    output reg  [23:0] SAMPLE,
    output reg SAMPLE_VALID
);

localparam I2S_SAMPLE_WIDTH = 24; 

reg [I2S_SAMPLE_WIDTH-1:0] SAMPLE_i;
reg [31: 0] SD_P; 

reg WS_R; //to check for transitions on the WS signal


assign SCK = i2s_clk;  

always @(posedge i2s_clk) begin
    WS_R <= WS; 
    SAMPLE_VALID <= 1'B0;     
    SD_P <= (SD_P<<1'B1)|SD;

    if ((WS && ~WS_R)) begin
        SAMPLE <= SD_P [30 -: I2S_SAMPLE_WIDTH];
        SAMPLE_VALID <= 1'b1; // only left channel is used here
    end

    if (reset)
        SAMPLE_VALID <= 1'b0; //last assignment wins
    
end
// initial begin
//     $dumpfile("i2s_receiver.vcd");
//     $dumpvars(0, i2s_receiver);
// end

endmodule