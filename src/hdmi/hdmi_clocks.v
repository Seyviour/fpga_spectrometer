//reference implementation is https://github.com/juj/HDMI_testikuva/blob/master/src/top.v + Gowin docs
`timescale 1 ns/10 ps
module hdmi_clock_gen #(
    parameter
    SIM=1
) 

(
    input wire clk,
    output reg hdmi_clk_5x,
    output reg hdmi_clk,
    output wire hdmi_clk_lock
);
    
localparam CLK_25_2_PERIOD = 40ns;
localparam CLK_126_PERIOD = 8ns; 


reg hdmi_clk_5x_i, hdmi_clk_i; 


//IMPLEMENT AS NECESSARY
//IMPLEMENTATION HERE IS GOWIN SPECIFIC
assign hdmi_clk_lock = hdmi_clk_lock_i;
wire hdmi_clk_lock_i; 

generate
if (!SIM) begin   

    Gowin_rPLL this_clock_mult(
        .clkin(clk), 
        .clkout(hdmi_clk_5x),
        .lock(hdmi_clk_lock_i)
    ); 

    
    CLKDIV #(.DIV_MODE("5"), .GSREN("false")) hdmi_clock_div
        (
            .HCLKIN(hdmi_clk_5x),
            .RESETN(hdmi_clk_lock_i),
            .CALIB(1'b1),
            .CLKOUT(hdmi_clk)
        );
    end 
 endgenerate

 if(SIM) begin
    assign hdmi_clk_5x = hdmi_clk_5x_i;
    assign hdmi_clk = hdmi_clk_i;
    always # (CLK_126_PERIOD/2) hdmi_clk_5x_i = ~hdmi_clk_5x_i;
    always # (CLK_25_2_PERIOD/2) hdmi_clk_i = ~hdmi_clk_i; 

end

initial begin
    hdmi_clk_5x_i = 1'b0;
    hdmi_clk_i = 1'b0;  
end 

endmodule
