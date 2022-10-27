module i2sMicSim #(
    parameter
    LFSR_WIDTH=16
) (
    input wire SCK,
    input wire reset, 
    output wire WS,
    output wire SD
);

assign WS = WS_counter[5]; 

reg [5:0] WS_counter;

always @(posedge SCK) begin
    if (reset)
        WS_counter <= 0;
    else 
        WS_counter <= WS_counter + 1'b1; 
end


LFSR #(.NUM_BITS (LFSR_WIDTH)) i2sLSFR 
    (
        .i_Clk (SCK),
        .i_Enable (1'B1),
        .i_Seed_DV (0),
        .i_Seed_Data (0),
        .o_LFSR_bit (SD),
        .o_LFSR_Data (),
        .o_LFSR_Done  ()
    );


endmodule