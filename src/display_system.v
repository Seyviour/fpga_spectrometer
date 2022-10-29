module displaySystem #(
    parameter
    FFT_SIZE=256,
    DATA_WIDTH=4
) (
    input wire hdmi_clk,
    input wire hdmi_clk_lock,
    input wire reset,
    input wire [DATA_WIDTH-1:0] data_rd,
    input wire [IDX_WIDTH-1:0] OLDEST_FFT_IDX,

    output wire [NO_BANKS-1:0] bank_rd,
    output wire [RAM_ADDR_WIDTH-1:0] addr_rd,
    output reg [23:0] rgb,
    output wire [2:0] hve
);

assign hve = hve_sync_d;



localparam IDX_WIDTH=$clog2(NO_FFTS);
localparam COORDW=16;
localparam NO_BANKS=2;
localparam NO_FFTS=50;
localparam RAM_ADDR_WIDTH=12;

localparam HORIZONTAL_BIAS = (COORDW)'(64);
localparam HORIZONTAL_DRAW_END = (COORDW)'(HORIZONTAL_BIAS + 512-1);
localparam VERTICAL_BIAS = (COORDW)'(40);
localparam VERTICAL_DRAW_END = (COORDW)'(40 + 400-1);

localparam [23:0] OUTSIDE_BOX_RGB = {8'D0, 8'D0, 8'D45}; 

reg outside_box, outside_box_d;


wire [COORDW-1:0] sx, sy;
wire [2:0] hve_sync, hve_sync_d;
wire hsync, vsync, de, frame, line;

wire i_reset;
assign i_reset = (reset | ~hdmi_clk_lock);

display_signal2  this_display1(
      .clk_pix (hdmi_clk),
      .rst_pix (i_reset),               
      .hvesync(hve_sync),
      .sx(sx),
      .sy(sy)
    );

coord_to_ram #(.NO_BANKS(NO_BANKS ),.COORDW(COORDW), 
    .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),.NO_FFTS (NO_FFTS )) thisCoordToRAM 
    (
        .clk(hdmi_clk),
        .x (sx),
        .y (sy),
        .OLDEST_FFT_IDX (OLDEST_FFT_IDX),
        .rd_bank_select (bank_rd),
        .rd_address  (addr_rd)
    );

delayShiftRegister #(.DATA_WIDTH(1), .DELAY_CYCLES(5)) thisBoundingDelay 
    (
        .clk(hdmi_clk),
        .datain(outside_box),
        .dataout(outside_box_d)
    );


delayShiftRegister #(.DATA_WIDTH(3), .DELAY_CYCLES(6)) thisSyncDelay 
    (
        .clk(hdmi_clk),
        .datain(hve_sync),
        .dataout(hve_sync_d)
    );

always @(*)
    outside_box = ((sx<HORIZONTAL_BIAS || sx>HORIZONTAL_DRAW_END) || (sy < VERTICAL_BIAS || sy > VERTICAL_DRAW_END));

always @(posedge hdmi_clk) begin
    if (outside_box_d)
        rgb <= OUTSIDE_BOX_RGB;
    else
        rgb <= {{data_rd, data_rd}, 8'b0, 8'b0};
end


endmodule