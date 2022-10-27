//CREDIT TO PROJECTF.IO. GREAT RESOURCE FOR LEARNING ABOUT VIDEO!

module display_signal2 #(
  parameter
  COORDW=16,
  H_RES=640,
  V_RES=480,
  H_FP=16,
  H_SYNC=96,
  H_BP=48,
  V_FP=10,
  V_SYNC=2,
  V_BP=33,
  H_POL=0,
  V_POL=0
) (
  input wire clk_pix, 
  input wire rst_pix,
  output wire [2:0] hvesync, 
  output reg frame, 
  output reg line,
  output reg signed [COORDW-1:0] sx,
  output reg signed [COORDW-1:0] sy
);

assign hvesync = {hsync, vsync, de};

reg hsync, vsync, de; 

localparam signed H_STA = 0 - H_FP - H_SYNC - H_BP;
localparam signed HS_STA = H_STA + H_FP;
localparam signed HS_END = HS_STA + H_SYNC;
localparam signed HA_STA = 0;
localparam signed HA_END = H_RES - 1;


localparam signed V_STA = 0 - V_FP - V_SYNC - V_BP;
localparam signed VS_STA = V_STA + V_FP;
localparam signed VS_END = VS_STA + V_SYNC;
localparam signed VA_STA = 0;
localparam signed VA_END = V_RES - 1;

reg signed [COORDW-1:0] x, y;

always @(posedge clk_pix) begin
  hsync <= H_POL ? (x > HS_STA && x <= HS_END) : ~(x > HS_STA && x <= HS_END);
  vsync <= V_POL ? (y > VS_STA && y <= HS_END) : ~(y > VS_STA && y <= HS_END);

  if (rst_pix) begin
    hsync <= H_POL ? 0 : 1;
    vsync <= V_POL ? 0 : 1;
  end

end


always @(posedge clk_pix) begin
  de <= (y >= VA_STA && x >= HA_STA);
  frame <= (y == V_STA && x == H_STA);
  line <= (x==H_STA);

  if (rst_pix) begin
    de <= 0;
    frame <= 0;
    line <= 0;
  end
end

always @(posedge clk_pix) begin
  if (x == HA_END) begin
    x <= COORDW'(H_STA);
    y <= (y == VA_END) ? (COORDW)'(V_STA): y + 1'b1;
  end else begin
    x <= x + 1'b1;
  end

  if (rst_pix) begin
    x <= COORDW'(H_STA);
    y <= COORDW'(V_STA); 
  end
end

always @(posedge clk_pix) begin
//    if (rst_pix) begin
//        sx <= H_STA;
//        sy <= V_STA;
//    end else begin
        sx <= x;
        sy <= y;
//    end
  
end

endmodule