//1 CYCLE DELAY

module pulseDetectCount #(
    parameter
    COUNTHIGH = 20

) (
    input wire clk,
    input wire reset, 
    input wire wr_en, 
    output reg count_true,
    output reg pulse
);
// On a negative pulse of the wr_en signal
// count increment
    reg [$clog2(COUNTHIGH)-1: 0] count; 
    reg wr_en_R1;// wr_en_R2;


    always @(posedge clk) begin 
        if (reset) begin
            count <= 0;
            count_true <= 1'b0;
        end else begin
            if (pulse) begin
                if (count == COUNTHIGH-1) begin
                    count_true <= 1'b1; 
                    count <= 0;
                end else begin
                    count_true <= 1'b0; 
                    count <= count + 1'b1; 
                end
            end   
        end
    end

    always @(posedge clk) begin
        wr_en_R1 <= wr_en;
    end

    always @(*)
        pulse =  wr_en_R1 && ~wr_en;

    // assign pulse =
    // assign count_true = (count == COUNTHIGH-1)? 1'B1:1'B0; 

    // initial begin
    //     $dumpfile("pulseDetectCount.vcd");
    //     $dumpvars(0, pulseDetectCount);
    //     #1;
    // end


endmodule