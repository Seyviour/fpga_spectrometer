module i2s_clk_gen (
    input wire clk_in,
    input wire reset, 
    output wire i2s_clk
);
    //VENDOR SPECIFIC

wire i2s_clk_8x;
wire lock; 
rpll_i2s_clk_8x i2s_clk_8x(
        .clkout(i2s_clk_8x), //output clkout
        .clkin(clk_in) //input clkin
    );

gowin_i2s_clk_div_8 clk_div_8(
    .clkout(i2s_clk), //output clkout
    .hclkin(i2s_clk_8x), //input hclkin
    .resetn(lock) //input resetn
);

endmodule