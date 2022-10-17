//reference implementation is https://github.com/juj/HDMI_testikuva/blob/master/src/top.v + Gowin docs

module hdmi_clock_gen (
    input wire clk,
    output reg hdmi_clk_5x,
    output reg hdmi_clk,
    output wire hdmi_clk_lock
);
    

//IMPLEMENT AS NECESSARY
//IMPLEMENTATION HERE IS GOWIN SPECIFIC

wire hdmi_clk_lock; 

Gowin_rPLL this_clock_mult(
    .clkin(clk), 
    .clkout(hdmi_clk_5x)
    .lock(hdmi_clk_lock)
    );

CLKDIV #(.DIV_MODE("5"), .GSREN("false")) hdmi_clock_div
    (
        .HCLKIN(hdmi_clk_5x),
        .RESETN(hdmi_clk_lock),
        .CALIB(1'b1),
        .CLKOUT(hdmi_clk)
    );
endmodule
