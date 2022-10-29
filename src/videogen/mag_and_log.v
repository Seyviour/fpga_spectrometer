module magnitudeAndLog #(
    parameter
    WORD_WIDTH = 16
) (
    input wire clk,
    // input wire reset,
    input wire [WORD_WIDTH*2-1: 0] Xk,
    output reg [3:0] log
);



wire signed [WORD_WIDTH-1: 0] Xk_real, Xk_imag; 
assign Xk_real = Xk[WORD_WIDTH*2-1: WORD_WIDTH];
assign Xk_imag = Xk[WORD_WIDTH-1: 0];

reg signed [WORD_WIDTH*2-1: 0] Xk_real_sqr, Xk_imag_sqr; 

reg [WORD_WIDTH*2: 0] magnitude_sum; 

always @(*) begin
    //MAGNITUDE
    Xk_real_sqr = Xk_real * Xk_real;
    Xk_imag_sqr = Xk_imag * Xk_imag; 
    magnitude_sum = Xk_real_sqr + Xk_imag_sqr;
end

wire [23:0] DIN;
wire [7:0] DOUT;

assign DIN = magnitude_sum[WORD_WIDTH*2-:23];


Log2flowthru thisLog2 (
      .DIN (DIN ),
      .DOUT  ( DOUT)
    );

always @(posedge clk) begin
    log <= DOUT; 
end
// always @(posedge clk) begin
//     log <= (magnitude_sum[WORD_WIDTH*2:WORD_WIDTH*2-4+1]); 
// end

//I'LL JUST USE SCALING TILL I CAN FIGURE OUT THE LOG


// initial begin
//     $dumpfile("mag_log.vcd");
//     $dumpvars(0, magnitudeAndLog);
// end


    
endmodule