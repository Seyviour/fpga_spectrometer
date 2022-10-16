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

reg [WORD_WIDTH*2-1: 0] Xk_real_sqr, Xk_imag_sqr; 

reg [WORD_WIDTH*2: 0] magnitude_sum; 

always @(posedge clk) begin

    //MAGNITUDE
    Xk_real_sqr <= Xk_real * Xk_real;
    Xk_imag_sqr <= Xk_imag * Xk_imag; 
    
end

always @(*) begin
    magnitude_sum = Xk_real_sqr + Xk_imag_sqr;
    log = magnitude_sum[WORD_WIDTH*2:WORD_WIDTH*2-4]; 
end

//I'LL JUST USE SCALING TILL I CAN FIGURE OUT THE LOG



    
endmodule