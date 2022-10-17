module hdmi_transmitter (
    input wire clk, reset, 

    
    input wire [23:0] rgb,
    output  wire [13: 0] o_sx, o_sy,
    output reg [3:0] hdmi_tx_n, 
    output reg [3:0] hdmi_tx_p
);



assign o_sx = sx;
assign o_sy = sy; 


wire hdmi_clk_5x, hdmi_clk, hdmi_clk_lock; 
hdmi_clock_gen this_hdmi_clock_gen (
  .clk (clk ),
  .hdmi_clk_5x (hdmi_clk_5x ),
  .hdmi_clk  ( hdmi_clk),
  .hdmi_clk_lock(hdmi_clk_lock)
);

wire reset_i;
assign reset_i = ~hdmi_clk_lock | ~reset;

wire [2:0] hve_sync; 
wire hsync, vsync, de, frame, line;

// reg [23: 0] rgb;
hdmi this_hdmi (
    .reset(reset_i),
    .hdmi_clk(hdmi_clk),
    .hdmi_clk_5x(hdmi_clk_5x),
    .hve_sync(hve_sync),
    .rgb(rgb),
    .hdmi_tx_n (hdmi_tx_n),
    .hdmi_tx_p (hdmi_tx_p)
);

wire [13: 0] sx, sy;


//vid480p vid480p_dut (
//  .clk_pix (hdmi_clk ),
//  .rst_pix (reset ),
//  .hsync (hsync ),
//  .vsync (vsync),
//  .de (de),
//  .frame (frame),
//  .line (line),
//  .sx (sx),
//  .sy (sy)
//);

display_signal  this_display1
(
  .i_pixel_clk (hdmi_clk),
  .i_reset(reset_i),               
  .o_hvesync(hve_sync),
  .o_x(sx),
  .o_y(sy)

);

endmodule

