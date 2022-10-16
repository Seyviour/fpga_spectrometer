//1 CYCLE DELAY

module pulseDetectCount #(
    parameter
    COUNTHIGH = 4410

) (
    input wire clk,
    input wire reset, 
    input wire wr_en, 
    output wire disp_wr_en
);

    reg [$clog2(COUNTHIGH)-1: 0] count; 
    reg wr_en_R;

    wire pulse;

    always @(posedge clk) begin 
        if (pulse)
            count <= count + 1'b1;
        if (reset)
            count <= 0; 
    end

    always @(posedge clk) begin
        wr_en_R <= wr_en; 
    end

    assign pulse = ~wr_en_R && wr_en;

    assign disp_wr_en = (count == COUNTHIGH-1) && wr_en_R; 

endmodule