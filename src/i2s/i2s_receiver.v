module i2s_receiver (
    input wire i2s_clk,
    input wire reset, 
    input wire SD,
    input wire WS,
    output wire SCK,
    output reg  [23:0] SAMPLE,
    output reg SAMPLE_VALID
);

reg [23:0] SAMPLE_i;
reg WS_R; 
reg [23: 0] SD_P; 
reg [4:0] idx;
assign SCK = i2s_clk;  

always @(posedge i2s_clk) begin

    if (reset) begin
        SAMPLE <= 0; 
        idx <= 5'b0;
        SAMPLE_VALID <= 1'b0;
        WS_R <= WS; 
        SD_P <= 24'b0;

    end else begin
        WS_R <= WS;
        if ((WS == ~WS_R)) begin
            idx <= 5'b0;
            SAMPLE <= SD_P;
            SD_P <= 0;
            SAMPLE_VALID <= (~WS_R) ? 1'b1: 1'b0; 
        end else begin
            SAMPLE_VALID <= 1'b0; 
            idx <= idx + 1'b1;
            SD_P[23-idx] <= SD; 
        end
    end
end
initial begin
    $dumpfile("i2s_receiver.vcd");
    $dumpvars(0, i2s_receiver);
end

// genvar i;
// generate
//     for (i=0; i<24; i=i+1) begin: REVERSE_BITS
//         assign SAMPLE[i] = SAMPLE_i[i];
//     end
// endgenerate
    

    
endmodule