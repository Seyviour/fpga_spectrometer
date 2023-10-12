module spectroTOP #(
    parameter
    COUNTHIGH = 4000,
    TWIDDLE_FILE = "",
    WORD_WIDTH = 16,
    FFT_SIZE = 128,
    NO_FFTS = 50,
    NO_BANKS = 2,
    ADDRESS_WIDTH = 12
) (
    input wire clk,
    input wire reset,
    input wire SD,
    input wire WS,

    output wire SCK,
    output wire [3:0] hdmi_tx_n,
    output wire [3:0] hdmi_tx_p

);
localparam COORDW = 10;

wire o_ip_disp_wr_en;
wire [$clog2(FFT_SIZE/2)-1: 0] o_ip_disp_wr_idx;
wire [WORD_WIDTH*2-1 :0] o_ip_disp_wr_data; 


// i2s_receiver this_i2s_receiver (
//   .i2s_clk (i2s_clk ),
//   .reset (reset ),
//   .SD (SD ),
//   .WS (WS ),
//   .SCK (SCK ),
//   .SAMPLE (SAMPLE ),
//   .SAMPLE_VALID  ( SAMPLE_VALID)
// );


inputAndProcessing #(.TWIDDLE_FILE(TWIDDLE_FILE ),.WORD_WIDTH(WORD_WIDTH ), .FFT_SIZE (FFT_SIZE )) thisInputAndProcessing (
  .clk27 (clk ),
  .reset (reset ),
  .SD (SD ),
  .WS (WS ),
  .SCK (SCK ),
  .disp_wr_en (o_ip_disp_wr_en),
  .disp_wr_idx (o_ip_disp_wr_idx),
  .disp_wr_data  ( o_ip_disp_wr_data)
);


wire signed [$clog2(NO_FFTS): 0] OLDEST_FFT_IDX;
wire o_dm_disp_wr_en;
wire [3:0] o_dm_disp_wr_data;
wire [11: 0] o_dm_wr_address; 
wire [NO_BANKS-1: 0] o_dm_bank_select; 

dispManager #(.COUNTHIGH(COUNTHIGH ), .FFT_SIZE(FFT_SIZE ), .WORD_WIDTH(WORD_WIDTH ), .NO_FFTS (NO_FFTS )) thisDisplayManager (
    .clk (clk),
    .reset (reset),
    .wr_en (o_ip_disp_wr_en),
    .i_address (o_ip_disp_wr_idx),
    .i_data (o_ip_disp_wr_data),

    .OLDEST_FFT_IDX (OLDEST_FFT_IDX ),
    .disp_wr_en (o_dm_disp_wr_en ),
    .wr_data (o_dm_disp_wr_data ),
    .wr_address  (o_dm_wr_address),
    .bank_select (o_dm_bank_select)
    );

wire [NO_BANKS-1: 0] i_bR_rd_bank_select; 
wire [ADDRESS_WIDTH-1: 0] i_br_rd_address;
wire [3:0] rd_data;


wire [1:0] br_wr_en;
assign br_wr_en = {o_dm_disp_wr_en, o_dm_disp_wr_en} & o_dm_bank_select;
bankRAM #(.no_banks(2),.word_width(4),.address_width (12)) thisRAMBank (
    .clk (clk ),
    .wr_bank_select (o_dm_bank_select ),
    .rd_bank_select (i_bR_rd_bank_select ),
    .wr_en (br_wr_en),
    .wr_address (o_dm_wr_address ),
    .rd_address (i_br_rd_address ),
    .wr_data (o_dm_disp_wr_data ),
    .rd_data  ( rd_data)
    );

reg [23:0] rgb;
always @(*)
    rgb = {8'((rd_data*2)), 8'd120, 8'd120};


wire [13:0] sx, sy; 
hdmi_transmitter this_hdmi_transmitter (
      .clk (clk ),
      .reset (reset ),
      .rgb (rgb ),
      .o_sx (sx ),
      .o_sy (sy ),
      .hdmi_tx_n (hdmi_tx_n ),
      .hdmi_tx_p  ( hdmi_tx_p)
    );

wire [NO_BANKS-1: 0] o_cr_bank_select; 
coord_to_ram #(.NO_BANKS(NO_BANKS ),.COORDW(13 ), .RAM_ADDR_WIDTH(ADDRESS_WIDTH ),.NO_FFTS (NO_FFTS ))
    thisCoordToRAM (
      .x (sx ),
      .y (sy ),
      .OLDEST_FFT_IDX (OLDEST_FFT_IDX ),
      .rd_bank_select (i_bR_rd_bank_select ),
      .rd_address  ( i_br_rd_address)
    );
  
  


endmodule

