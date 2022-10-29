`timescale 1 ns/10 ps

module i2s_clk_gen #(
    parameter
    SIM=0
)(
    input wire clk_in,
    input wire reset, 
    output wire i2s_clk
);
    //VENDOR SPECIFIC
reg i2s_clk_i; 
wire i2s_clk_8x;
wire lock;
localparam i2s_SIM_PERIOD = 160;

generate
if (!SIM) begin 
    rpll_i2s_clk_8x i2s_clk_8x_m(
            .clkout(i2s_clk_8x), //output clkout
            .clkin(clk_in), //input clkin
            .lock_o(lock)
        );

    gowin_i2s_clk_div_8 clk_div_8(
        .clkout(i2s_clk), //output clkout
        .hclkin(i2s_clk_8x), //input hclkin
        .resetn(lock) //input resetn
    );
    end 
endgenerate

if (SIM) begin
    assign i2s_clk = i2s_clk_i;
    always #(i2s_SIM_PERIOD/2) i2s_clk_i = ~i2s_clk_i; 
end

initial begin
    i2s_clk_i = 0; 
end

endmodule